require "rails_helper"

RSpec.describe "Tooltip HTML", type: :system do
  let(:payload) { %(<img src="data:image/png;base64,x" onerror="window.tooltipPayloadRan = true">) }
  let!(:project) { create :project, name: "Apollo" }

  def with_discreet_tooltip(tooltip)
    previous = Avo::Resources::Project.discreet_information
    Avo::Resources::Project.discreet_information = [{tooltip:, icon: "heroicons/outline/academic-cap", data: {tooltip_trigger: true}}]
    yield
  ensure
    Avo::Resources::Project.discreet_information = previous
  end

  def stub_show_controls(*controls)
    allow_any_instance_of(Avo::Resources::Project).to receive(:render_show_controls).and_return(controls)
  end

  def tooltip_trigger = find("[data-tooltip-trigger][has-data-tippy]")

  # The image's error event fires a moment after Tippy parses the markup, so an immediate read proves nothing.
  def expect_payload_not_to_run
    sleep 0.5
    expect(page.evaluate_script("window.tooltipPayloadRan")).to be_nil
  end

  it "shows a plain tooltip as text and never runs its markup" do
    markup = payload
    with_discreet_tooltip(-> { markup }) do
      visit avo.resources_project_path(project)

      expect_payload_not_to_run
      tooltip_trigger.hover
      expect(page).to have_css(".tippy-content", exact_text: markup)
      expect(page).not_to have_css(".tippy-content img")
    end
  end

  it "shows a tippy_content value as text and never runs its markup" do
    stub_show_controls(Avo::Resources::Controls::ActionsList.new(title: payload, label: "Actions"))

    visit avo.resources_project_path(project)

    expect(page).to have_css("[data-tippy-content]", visible: :all)
    expect_payload_not_to_run
  end

  it "shows a tooltip that is not a string as text" do
    with_discreet_tooltip(-> { 5 }) do
      visit avo.resources_project_path(project)

      tooltip_trigger.hover
      expect(page).to have_css(".tippy-content", exact_text: "5")
    end
  end

  it "renders a safe tooltip as HTML" do
    with_discreet_tooltip(-> { sanitize("View <strong>site</strong>", tags: %w[strong]) }) do
      visit avo.resources_project_path(project)

      tooltip_trigger.hover
      expect(page).to have_css(".tippy-content strong", text: "site")
    end
  end

  it "renders a control's safe title as HTML" do
    title = ActionController::Base.helpers.tag.strong("Leave")
    stub_show_controls(Avo::Resources::Controls::BackButton.new(label: "Site", title:))

    visit avo.resources_project_path(project)

    find("[has-data-tippy]", text: "Site").hover
    expect(page).to have_css(".tippy-content strong", text: "Leave")
  end

  it "keeps text escaped inside a safe tooltip as text" do
    markup = payload
    with_discreet_tooltip(-> { tag.strong(markup) }) do
      visit avo.resources_project_path(project)

      expect_payload_not_to_run
      tooltip_trigger.hover
      expect(page).to have_css(".tippy-content strong", exact_text: markup)
    end
  end

  it "renders the same after a Turbo cache restore" do
    markup = payload
    previous = Avo::Resources::Project.discreet_information
    Avo::Resources::Project.discreet_information = [
      {tooltip: -> { tag.strong("Safe") }, icon: "heroicons/outline/academic-cap", data: {tooltip_trigger: "safe"}},
      {tooltip: -> { markup }, icon: "heroicons/outline/academic-cap", data: {tooltip_trigger: "plain"}}
    ]
    visit avo.resources_project_path(project)
    expect(page).to have_css("[data-tooltip-trigger][has-data-tippy]", count: 2)

    page.execute_script("Turbo.visit('#{avo.resources_projects_path}')")
    expect(page).to have_current_path(avo.resources_projects_path, ignore_query: true)
    page.go_back

    find("[data-tooltip-trigger='safe'][has-data-tippy]").hover
    expect(page).to have_css(".tippy-content strong", text: "Safe")
    find("[data-tooltip-trigger='plain'][has-data-tippy]").hover
    expect(page).to have_css(".tippy-content", exact_text: markup)
    expect_payload_not_to_run
  ensure
    Avo::Resources::Project.discreet_information = previous
  end

  it "keeps the line break in the timestamps tooltip" do
    previous = Avo::Resources::Project.discreet_information
    Avo::Resources::Project.discreet_information = :timestamps
    visit avo.resources_project_path(project)

    find("[has-data-tippy*='Created at']").hover
    expect(page).to have_css(".tippy-content br")
  ensure
    Avo::Resources::Project.discreet_information = previous
  end
end
