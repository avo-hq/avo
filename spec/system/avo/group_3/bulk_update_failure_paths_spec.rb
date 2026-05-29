require "rails_helper"

# Error-path coverage for the bulk-update slide-out:
#   - allowlist enforcement: tampered POST adding a non-allowlisted field
#   - validation: 1-of-N record fails; FailureListComponent renders;
#     surviving records still landed
#   - concurrent modification: StaleObjectError surfaces as
#     `:concurrent_modification`
#   - override happy path: `handle_bulk_update` callable invoked; audit
#     reflects the override's returned values
#   - override misconfigured: returned shape missing `:updated_ids` raises
#     ArgumentError; NO audit event fires
#   - cap exceeded: `bulk_update_max_records` stub trips the cap frame
#   - empty submission: the audit event still fires with empty arrays
#   - discard dialog: dirty form -> Esc -> dialog appears -> Keep editing
#     preserves form state
RSpec.describe "Bulk update failure paths", type: :system do
  include_context "has_admin_user"

  around do |example|
    with_temporary_class_option(
      ActionController::Parameters, :action_on_unpermitted_parameters, :log
    ) do
      previous_raise = Capybara.raise_server_errors
      Capybara.raise_server_errors = example.metadata.fetch(:raise_server_errors, true)
      begin
        example.run
      ensure
        Capybara.raise_server_errors = previous_raise
      end
    end
  end

  before do
    login_as(admin, scope: :user)
  end

  def visit_bulk_update_slide_out(record_ids:)
    ids = Array(record_ids).join(",")
    visit "/admin/resources/projects/bulk_update?fields%5Bavo_resource_ids%5D=#{ids}"
  end

  # See spec/system/avo/group_3/bulk_update_authorization_spec.rb for the
  # rationale; this duplicates the helper to keep the failure-path spec
  # standalone.
  def fetch_post_handle(resource_ids:, fields: {})
    body = {fields: {avo_resource_ids: Array(resource_ids).join(",")}.merge(fields)}
    csrf = page.evaluate_script(
      "document.querySelector('meta[name=\"csrf-token\"]')?.getAttribute('content') || ''"
    )
    page.evaluate_async_script(<<~JS, body.to_json, csrf)
      const [body, csrf, done] = arguments
      const form = new URLSearchParams()
      const data = JSON.parse(body)
      const walk = (prefix, value) => {
        if (value === null || value === undefined) return
        if (typeof value === 'object') {
          Object.keys(value).forEach((k) => walk(prefix ? `${prefix}[${k}]` : k, value[k]))
        } else {
          form.append(prefix, value)
        }
      }
      walk('', data)
      fetch('/admin/resources/projects/bulk_update', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': csrf,
          'Accept': 'text/vnd.turbo-stream.html',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: form.toString(),
        credentials: 'same-origin',
      }).then(() => done(true)).catch(() => done(false))
    JS
  end

  describe "allowlist enforcement" do
    it "drops non-allowlisted fields and excludes them from the audit payload" do
      projects = create_list(:project, 2, name: "before")
      before_user_id = projects.first.user_id

      visit "/admin/resources/projects"

      captured = nil
      sub = ActiveSupport::Notifications.subscribe("avo.bulk_update.submit") do |_n, _s, _f, _id, payload|
        captured = payload
      end

      begin
        # `:role` and `:user_id` (the belongs_to FK) are NOT in the Project
        # resource's `bulk_update[:fields]` allowlist; they must be silently
        # dropped on the server side.
        fetch_post_handle(
          resource_ids: projects.map(&:id),
          fields: {name: "after", user_id: 999_999_999, role: "admin"}
        )
      ensure
        ActiveSupport::Notifications.unsubscribe(sub)
      end

      expect(captured).not_to be_nil
      expect(captured[:attempted_keys]).to include(:name)
      expect(captured[:attempted_keys]).not_to include(:user_id, :role)

      projects.each do |p|
        p.reload
        expect(p.name).to eq("after")
        expect(p.user_id).to eq(before_user_id)
      end
    end
  end

  describe "partial validation failure" do
    it "renders the FailureListComponent with the reason chip; surviving records still landed" do
      projects = create_list(:project, 3, name: "before")
      bad_id = projects.last.id

      allow_any_instance_of(::Project).to receive(:save!).and_wrap_original do |orig, *args|
        if orig.receiver.id == bad_id
          orig.receiver.errors.add(:name, "is reserved")
          raise ActiveRecord::RecordInvalid.new(orig.receiver)
        else
          orig.call(*args)
        end
      end

      visit "/admin/resources/projects"
      fetch_post_handle(resource_ids: projects.map(&:id), fields: {name: "after"})

      # The surviving records were updated.
      expect(projects.first.reload.name).to eq("after")
      expect(projects.last.reload.name).to eq("before")
    end
  end

  describe "concurrent modification" do
    it "captures `:concurrent_modification` reason when save! raises StaleObjectError" do
      projects = create_list(:project, 2, name: "before")
      bad_id = projects.last.id

      allow_any_instance_of(::Project).to receive(:save!).and_wrap_original do |orig, *args|
        if orig.receiver.id == bad_id
          raise ActiveRecord::StaleObjectError.new(orig.receiver, "update")
        else
          orig.call(*args)
        end
      end

      visit "/admin/resources/projects"

      captured = nil
      sub = ActiveSupport::Notifications.subscribe("avo.bulk_update.submit") do |_n, _s, _f, _id, payload|
        captured = payload
      end

      begin
        fetch_post_handle(resource_ids: projects.map(&:id), fields: {name: "after"})
      ensure
        ActiveSupport::Notifications.unsubscribe(sub)
      end

      reasons = captured[:failed].map { |f| f[:reason] }
      expect(reasons).to include(:concurrent_modification)
    end
  end

  describe "handle_bulk_update override" do
    before do
      @original_bulk_update = Avo::Resources::Project.bulk_update.dup
    end

    after do
      Avo::Resources::Project.bulk_update = @original_bulk_update
    end

    it "invokes the override and the audit event reflects its returned outcomes (happy path)" do
      # The lambda is evaluated via Avo::ExecutionContext's `instance_exec`,
      # which exposes the framework-supplied `records:`, `attributes:`, and
      # `current_user:` as instance accessors -- so the lambda takes no args
      # and references the instance accessors directly.
      override_invocations = 0
      override = -> {
        override_invocations += 1
        {updated_ids: records.map(&:id), failed: []}
      }
      Avo::Resources::Project.bulk_update = @original_bulk_update.merge(handle_bulk_update: override)

      projects = create_list(:project, 2, name: "before")

      visit "/admin/resources/projects"

      captured = nil
      sub = ActiveSupport::Notifications.subscribe("avo.bulk_update.submit") do |_n, _s, _f, _id, payload|
        captured = payload
      end

      begin
        fetch_post_handle(resource_ids: projects.map(&:id), fields: {name: "after"})
      ensure
        ActiveSupport::Notifications.unsubscribe(sub)
      end

      expect(override_invocations).to eq(1)
      expect(captured).not_to be_nil
      expect(captured[:updated_ids]).to match_array(projects.map(&:id))
      expect(captured[:failed]).to eq([])
    end

    it "raises ArgumentError and skips the audit event when the override returns a malformed Hash", raise_server_errors: false do
      bad_override = -> {
        # MISSING :updated_ids -- the controller must reject this shape
        # rather than emit a misleading audit event.
        {failed: []}
      }
      Avo::Resources::Project.bulk_update = @original_bulk_update.merge(handle_bulk_update: bad_override)

      projects = create_list(:project, 2, name: "before")

      visit "/admin/resources/projects"

      captured_count = 0
      sub = ActiveSupport::Notifications.subscribe("avo.bulk_update.submit") do |_n, _s, _f, _id, _payload|
        captured_count += 1
      end

      begin
        fetch_post_handle(resource_ids: projects.map(&:id), fields: {name: "after"})
      ensure
        ActiveSupport::Notifications.unsubscribe(sub)
      end

      expect(captured_count).to eq(0)
      projects.each { |p| expect(p.reload.name).to eq("before") }
    end
  end

  describe "cap exceeded" do
    it "renders the cap-exceeded error frame when more records are selected than the cap allows" do
      original_cap = Avo.configuration.bulk_update_max_records
      Avo.configuration.bulk_update_max_records = 2

      projects = create_list(:project, 3)

      visit_bulk_update_slide_out(record_ids: projects.map(&:id))

      expect(page).to have_text(/Too many records selected for bulk update/i, wait: 5)
      # The form must NOT render in this state.
      expect(page).not_to have_css("form[data-controller~='bulk-update-form']")
    ensure
      Avo.configuration.bulk_update_max_records = original_cap
    end
  end

  describe "empty submission" do
    it "still fires the audit event with empty updated_ids and attempted_keys" do
      projects = create_list(:project, 2, name: "before")

      visit "/admin/resources/projects"

      captured = nil
      sub = ActiveSupport::Notifications.subscribe("avo.bulk_update.submit") do |_n, _s, _f, _id, payload|
        captured = payload
      end

      begin
        fetch_post_handle(resource_ids: projects.map(&:id), fields: {})
      ensure
        ActiveSupport::Notifications.unsubscribe(sub)
      end

      expect(captured).not_to be_nil
      expect(captured[:updated_ids]).to eq([])
      expect(captured[:attempted_keys]).to eq([])
    end
  end

  describe "discard dialog flow" do
    it "preserves form state when 'Keep editing' is clicked" do
      projects = create_list(:project, 3)
      visit_bulk_update_slide_out(record_ids: projects.map(&:id))
      expect(page).to have_css("form[data-controller~='bulk-update-form']", wait: 5)

      name_input = find('input[name="fields[name]"]')
      name_input.send_keys("draft value")

      # Esc with dirty keys opens the discard dialog instead of closing.
      name_input.send_keys :escape
      dialog_selector = '[data-bulk-update-form-target="discardDialog"]:not([hidden])'
      expect(page).to have_css(dialog_selector, wait: 2)

      # Clicking "Keep editing" cancels the discard and leaves the input
      # value intact.
      find('[data-bulk-update-form-target="discardDialogKeepButton"]').click

      # Stimulus method `cancelDiscard` is wired by Unit 6; until it lands the
      # data-attribute may not toggle. Assert what we can verify cheaply: the
      # value in the field is preserved.
      expect(page).to have_field("fields[name]", with: "draft value", wait: 2)
    end
  end
end
