require "rails_helper"

RSpec.describe Avo::Index::FieldWrapperComponent, type: :component do
  let(:record) { Project.new(name: "Apollo") }
  let(:resource) { Avo::Resources::Project.new(record:, view: :index) }

  # A bare <td> is dropped by the HTML5 fragment parser, so render the
  # wrapper on the :div host the dashboards list card uses.
  def render_wrapper(field, **args, &block)
    render_inline(described_class.new(field:, resource:, html_tag: :div, dash_if_blank: false, **args), &block)
  end

  it "anchors the value tooltip to the value inside the cell" do
    field = Avo::Fields::BadgeField.new(:status, tooltip: "Revoked at 2026-09-23")
      .hydrate(record:, resource:, view: :index)

    render_wrapper(field) { "Revoked" }

    anchor = page.find("[data-field-id='status'] > .tooltip-anchor")

    expect(anchor[:title]).to eq "Revoked at 2026-09-23"
    expect(anchor["data-tippy"]).to eq "tooltip"
    expect(anchor[:class]).to include("tooltip-anchor--inline")
    expect(anchor).to have_text "Revoked"
  end

  it "keeps the anchor inside the centering wrapper" do
    field = Avo::Fields::BooleanField.new(:active, tooltip: "Since launch")
      .hydrate(record:, resource:, view: :index)

    render_wrapper(field, center_content: true) { "Yes" }

    expect(page).to have_css("[data-field-id='active'] > .flex > .tooltip-anchor[title='Since launch']")
  end

  it "keeps the tooltip on the dash of a blank value" do
    field = Avo::Fields::TextField.new(:name, tooltip: "Not named yet")
      .hydrate(record: Project.new, resource:, view: :index)

    render_wrapper(field, dash_if_blank: true) { "" }

    expect(page.find(".tooltip-anchor[title='Not named yet']")).to have_text "—"
  end

  it "renders the value bare without a tooltip" do
    field = Avo::Fields::TextField.new(:name).hydrate(record:, resource:, view: :index)

    render_wrapper(field) { "Apollo" }

    expect(page).not_to have_css(".tooltip-anchor")
    expect(page).not_to have_css("[data-tippy]")
    expect(page.find("[data-field-id='name']")).to have_text "Apollo"
  end
end
