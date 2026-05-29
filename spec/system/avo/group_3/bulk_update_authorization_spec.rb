require "rails_helper"

# Authorization-filter coverage for the bulk-update slide-out.
#
# `lib/avo/services/authorization_service.rb` is an OSS no-op shim
# (`authorize_action` always returns true). To exercise the K-of-N filter,
# the "no records editable" frame, and the `unauthorized_at_write` failure
# reason in OSS, we stub `authorize_action` per record. The Pro authorization
# client wires the same `authorize_action` surface so this stub mirrors the
# real production code path.
RSpec.describe "Bulk update authorization filter", type: :system do
  include_context "has_admin_user"

  around do |example|
    with_temporary_class_option(
      ActionController::Parameters, :action_on_unpermitted_parameters, :log
    ) { example.run }
  end

  before do
    login_as(admin, scope: :user)
  end

  def stub_authorization_per_record(allowed_ids:)
    allow_any_instance_of(Avo::Services::AuthorizationService)
      .to receive(:authorize_action) do |service, _action, **|
        record = service.record
        # Class-level / nil checks bypass the filter; record-level checks are
        # the ones we want to gate per allowed_ids.
        next true unless record.is_a?(::Project)
        allowed_ids.include?(record.id)
      end
  end

  def visit_bulk_update_slide_out(record_ids:)
    ids = Array(record_ids).join(",")
    visit "/admin/resources/projects/bulk_update?fields%5Bavo_resource_ids%5D=#{ids}"
  end

  describe "K-of-N filter" do
    it "renders 'Updating 3 of 5' banner when 2 of 5 selected records are unauthorized" do
      projects = create_list(:project, 5, name: "before")
      allowed = projects.first(3)
      stub_authorization_per_record(allowed_ids: allowed.map(&:id))

      visit_bulk_update_slide_out(record_ids: projects.map(&:id))

      expect(page).to have_css("form[data-controller~='bulk-update-form']", wait: 5)
      within(".bulk-update-banner") do
        expect(page).to have_text(/Updating\s+3\s+of\s+5/i)
        expect(page).to have_text(/2 records were excluded/i)
      end
    end
  end

  describe "0 of N authorized" do
    it "renders the 'no records editable' frame instead of the form" do
      projects = create_list(:project, 3)
      stub_authorization_per_record(allowed_ids: [])

      visit_bulk_update_slide_out(record_ids: projects.map(&:id))

      expect(page).to have_text(/No selected records are editable by you/i, wait: 5)
      # The form must NOT render in this state -- the controller bails to the
      # error frame and the user can only Close.
      expect(page).not_to have_css("form[data-controller~='bulk-update-form']")
    end
  end

  # Issue a direct fetch against the bulk-update handle endpoint with a
  # custom body. Bypasses the Stimulus form controller's in-flight gating so
  # the test stays focused on the SERVER's authz semantics (which is the
  # contract under test here). The browser carries over Devise's session
  # cookie so we hit the controller authenticated.
  def fetch_post_handle(resource_ids:, fields: {})
    body = {fields: {avo_resource_ids: Array(resource_ids).join(",")}.merge(fields)}
    csrf = page.evaluate_script(
      "document.querySelector('meta[name=\"csrf-token\"]')?.getAttribute('content') || ''"
    )
    page.evaluate_async_script(<<~JS, body.to_json, csrf)
      const [body, csrf, done] = arguments
      const form = new URLSearchParams()
      const append = (k, v) => form.append(k, v)
      // Flatten the JSON body to fields[name]=value pairs.
      const data = JSON.parse(body)
      const walk = (prefix, value) => {
        if (value === null || value === undefined) return
        if (typeof value === 'object') {
          Object.keys(value).forEach((k) => walk(prefix ? `${prefix}[${k}]` : k, value[k]))
        } else {
          append(prefix, value)
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

  describe "POST tamper: adding an unauthorized record ID" do
    # The hidden `avo_resource_ids` is untrusted user input on every request.
    # When the tampered record passes the open-time filter (the attacker
    # crafted a stale-but-once-authorized ID, or authz drifted), the write-time
    # re-check inside the default loop catches it and surfaces it as
    # `:unauthorized_at_write`. This matches the request spec's authz-drift
    # scenario via the live form route.
    it "surfaces records that lose update? at write time as `:unauthorized_at_write`" do
      projects = create_list(:project, 3, name: "before")
      target_drift_id = projects.last.id

      # Same shape as the authz-drift scenario below: allow the first :update
      # call on the drifted record (open-time filter), deny the second
      # (write-time loop re-check). Mirrors a tampered POST whose extra ID was
      # once authorized but no longer is at write time.
      drift_update_calls = 0
      allow_any_instance_of(Avo::Services::AuthorizationService)
        .to receive(:authorize_action).and_wrap_original do |original, *args, **kwargs|
          service = original.receiver
          record = service.record
          action = args.first
          if record.is_a?(::Project) && record.id == target_drift_id && action == :update
            drift_update_calls += 1
            next drift_update_calls == 1
          end
          true
        end

      # Land on the index first so we have a valid Devise session + CSRF token
      # available to the fetch script. The visit does NOT exercise the
      # bulk-update path, so it leaves the call_count counter at zero.
      visit "/admin/resources/projects"

      captured_payloads = []
      sub = ActiveSupport::Notifications.subscribe("avo.bulk_update.submit") do |_n, _s, _f, _id, payload|
        captured_payloads << payload
      end

      begin
        fetch_post_handle(
          resource_ids: projects.map(&:id),
          fields: {name: "after"}
        )
      ensure
        ActiveSupport::Notifications.unsubscribe(sub)
      end

      payload = captured_payloads.last
      expect(payload).not_to be_nil
      reasons = payload[:failed].map { |f| f[:reason] }
      expect(reasons).to include(:unauthorized_at_write)
    end
  end

  describe "authz drift between open and submit" do
    # The slide-out renders against an open-time authorized set, but the POST
    # re-runs the per-record `update?` check. If a record loses authorization
    # between open and submit, it must show up as `:unauthorized_at_write`.
    it "marks records that lose update? between open and submit as `:unauthorized_at_write`" do
      projects = create_list(:project, 3, name: "before")
      target_drift_id = projects.last.id

      # The controller calls `authorize_action(:update, ...)` for the drifted
      # record twice on the bulk-update path: once during the open-time
      # `authorized` filter, once again inside the default loop's re-check.
      # We allow the first :update call against this record and deny the
      # second, leaving other actions (e.g., :show / :index / save! callback
      # checks) unaffected.
      drift_update_calls = 0
      allow_any_instance_of(Avo::Services::AuthorizationService)
        .to receive(:authorize_action).and_wrap_original do |original, *args, **kwargs|
          service = original.receiver
          record = service.record
          action = args.first
          if record.is_a?(::Project) && record.id == target_drift_id && action == :update
            drift_update_calls += 1
            next drift_update_calls == 1
          end
          true
        end

      # Land on the index first so we have a valid Devise session + CSRF token
      # available to the fetch script. The visit does NOT exercise the
      # bulk-update path, so it leaves the call_count counter at zero.
      visit "/admin/resources/projects"

      captured_payloads = []
      sub = ActiveSupport::Notifications.subscribe("avo.bulk_update.submit") do |_n, _s, _f, _id, payload|
        captured_payloads << payload
      end

      begin
        fetch_post_handle(
          resource_ids: projects.map(&:id),
          fields: {name: "after"}
        )
      ensure
        ActiveSupport::Notifications.unsubscribe(sub)
      end

      payload = captured_payloads.last
      expect(payload).not_to be_nil, "audit notification never fired; fetch_post_handle may have failed (drift_update_calls=#{drift_update_calls})"
      reasons = payload[:failed].map { |f| f[:reason] }
      expect(reasons).to include(:unauthorized_at_write),
        "expected :unauthorized_at_write in payload; got payload=#{payload.inspect} drift_update_calls=#{drift_update_calls}"
    end
  end
end
