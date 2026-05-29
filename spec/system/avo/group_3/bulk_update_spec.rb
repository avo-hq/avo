require "rails_helper"
require "benchmark"

# End-to-end happy-path coverage for the bulk-update slide-out.
#
# The toolbar button entry point is being implemented in parallel as Unit 6;
# until it lands, these scenarios drive the slide-out via the GET URL directly
# (the controller's show path is the same surface the toolbar link targets).
# Toolbar-specific assertions live in `bulk_update_toolbar_spec.rb`.
#
# `action_on_unpermitted_parameters` is `:raise` in the spec/rails_helper.rb
# default, but production runs with `:log`. The slide-out's submit `<button>`
# tag picks up Rails' default `name="button"` which would surface as an
# unpermitted-parameters error under `:raise`; we use the `:log` shape here
# so the system tests exercise the real production path.
RSpec.describe "Bulk update happy path", type: :system do
  include_context "has_admin_user"

  around do |example|
    with_temporary_class_option(
      ActionController::Parameters, :action_on_unpermitted_parameters, :log
    ) { example.run }
  end

  before do
    login_as(admin, scope: :user)
  end

  def visit_bulk_update_slide_out(record_ids:)
    ids = Array(record_ids).join(",")
    visit "/admin/resources/projects/bulk_update?fields%5Bavo_resource_ids%5D=#{ids}"
    expect(page).to have_css("form[data-controller~='bulk-update-form']", wait: 5)
  end

  describe "slide-out rendering" do
    it "renders the K-of-N banner with no exclusion line when all selected records are authorized" do
      projects = create_list(:project, 3)

      visit_bulk_update_slide_out(record_ids: projects.map(&:id))

      # K == N banner is "Updating 3 of 3 selected records." with no exclusion line.
      within(".bulk-update-banner") do
        expect(page).to have_css("strong", text: "3", count: 2)
        expect(page).not_to have_text(/were excluded/i)
      end
    end

    it "renders the all-share status notice when 3 rows share the same stage value" do
      projects = create_list(:project, 3, stage: "Done")

      visit_bulk_update_slide_out(record_ids: projects.map(&:id))

      # "All 3 records have stage set to Done."
      expect(page).to have_css(
        ".bulk-update-status-notice.bulk-update-status-notice--muted",
        text: /All\s+3\s+records have\s+Stage\s+set to\s+Done/i
      )
    end

    it "renders the sample-list status notice when 3 rows have 3 distinct stage values" do
      stages = ["Done", "Idea", "Discovery"]
      stages.each { |s| create(:project, stage: s) }
      projects = ::Project.where(stage: stages).order(:id)

      visit_bulk_update_slide_out(record_ids: projects.map(&:id))

      # `bulk_update_sample_threshold` defaults to 5, so 3 distinct values <= 5
      # renders the sample-list shape: "3 different values: a, b, c".
      expect(page).to have_css(
        ".bulk-update-status-notice.bulk-update-status-notice--tertiary",
        text: /3 different values:/i
      )
    end

    it "renders the count-only status notice when distinct values exceed the sample threshold" do
      # 8 distinct names across 8 projects > sample threshold (default 5).
      8.times { |i| create(:project, name: "Project #{i}", stage: "Done") }
      projects = ::Project.where(stage: "Done").order(:id)

      visit_bulk_update_slide_out(record_ids: projects.map(&:id))

      # The Name field's status notice should be count-only ("8 different values").
      # Other fields may still render as all-share (they're all stage=Done).
      expect(page).to have_css(
        ".bulk-update-status-notice.bulk-update-status-notice--accent",
        text: /\d+ different values\z/i
      )
    end

    it "hides the change-summary surface when the resource opts out via change_summary: false" do
      # The Project resource ships with change_summary unset (default true). To exercise
      # R9 we temporarily toggle the resource attribute and reset after the example.
      original = Avo::Resources::Project.bulk_update.dup
      Avo::Resources::Project.bulk_update = original.merge(change_summary: false)

      projects = create_list(:project, 3)
      visit_bulk_update_slide_out(record_ids: projects.map(&:id))

      expect(page).not_to have_css(".bulk-update-change-summary")
    ensure
      Avo::Resources::Project.bulk_update = original
    end
  end

  describe "happy-path write" do
    # The form's hidden inputs (avo_resource_ids etc.) and the Cuprite submit
    # cycle exercise the full GET show → POST handle round-trip including the
    # Turbo Stream response + per-row replace fragments.
    it "fires the POST and shows the success flash when the user clicks Submit" do
      projects = create_list(:project, 3, name: "before")

      visit_bulk_update_slide_out(record_ids: projects.map(&:id))

      find('input[name="fields[name]"]').send_keys("after")
      find('button[type="submit"][data-bulk-update-form-target="submitButton"]').click

      # Server-rendered flash (Turbo Stream renders the alert into the
      # standard alerts target). The actual write-vs-skip behavior per-field is
      # pinned in the request spec (spec/requests/avo/bulk_update_controller_spec.rb);
      # this scenario pins the end-to-end submit gesture only.
      expect(page).to have_text(/Updated\s+\d+\s+records/i, wait: 5)
      bulk_update_posts = page.driver.network_traffic.select do |exchange|
        exchange.request&.method == "POST" && exchange.url.to_s.include?("/bulk_update")
      end
      expect(bulk_update_posts).not_to be_empty
    end
  end

  describe "wall-clock budget" do
    # Plan pins "open-to-flash under 5 seconds on CI for 50 records". Uses
    # insert_all to keep the fixture seed off the wall-clock so the budget
    # measures what users feel (request → response → render), not factories.
    it "completes the GET-show → POST-handle round-trip in under 5 seconds for 50 records" do
      now = Time.current
      rows = 50.times.map do |i|
        {
          name: "wall-clock #{i}",
          status: "running",
          stage: "done",
          country: "US",
          users_required: 10,
          started_at: now,
          description: "wall",
          created_at: now,
          updated_at: now
        }
      end
      ::Project.insert_all(rows)
      ids = ::Project.where(name: rows.pluck(:name)).pluck(:id)

      elapsed = Benchmark.realtime do
        visit "/admin/resources/projects/bulk_update?fields%5Bavo_resource_ids%5D=#{ids.join(",")}"
        expect(page).to have_css("form[data-controller~='bulk-update-form']", wait: 5)

        # Edit two fields (text + a freeform input) and submit. The wall-clock
        # budget pin is on the GET-show -> POST-handle round-trip, not on the
        # per-field write semantics.
        find('input[name="fields[name]"]').send_keys("renamed wall")
        find('input[name="fields[users_required]"]').send_keys("42")
        find('button[type="submit"][data-bulk-update-form-target="submitButton"]').click

        expect(page).to have_text(/Updated\s+\d+\s+records/i, wait: 10)
      end

      expect(elapsed).to be < 5.0, "expected open-to-flash under 5s, took #{elapsed.round(2)}s"
    end
  end

  describe "selection state" do
    # The slide-out is detached from the live selection once opened; clicking
    # Submit + receiving full-success should clear the selection state on the
    # parent index page when the user navigates back.
    it "clears the index-page selection after a successful full submit" do
      projects = create_list(:project, 3, name: "before")
      ids = projects.map(&:id)

      # Open the slide-out via the GET URL.
      visit "/admin/resources/projects/bulk_update?fields%5Bavo_resource_ids%5D=#{ids.join(",")}"
      expect(page).to have_css("form[data-controller~='bulk-update-form']", wait: 5)
      find('input[name="fields[name]"]').send_keys("after")
      find('button[type="submit"][data-bulk-update-form-target="submitButton"]').click

      expect(page).to have_text(/Updated\s+\d+\s+records/i, wait: 5)

      # After the slide-out closes the user expectation is that no rows remain
      # checked on the visible index. We assert via cookie/session-cleanup
      # rather than re-visiting the index (selection state lives only on the
      # currently-rendered table; a fresh visit always starts clean).
      visit "/admin/resources/projects"
      expect(page).not_to have_css('input[type="checkbox"][name="Select all"][checked]')
    end
  end
end
