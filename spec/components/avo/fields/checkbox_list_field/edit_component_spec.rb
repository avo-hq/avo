require "rails_helper"

RSpec.describe Avo::Fields::CheckboxListField::EditComponent, type: :component do
  let(:record) { Team.new(name: "Avo") }
  let(:resource) { Avo::Resources::Team.new(record:, view: :edit) }
  let(:form) { ActionView::Helpers::FormBuilder.new(:team, record, vc_test_controller.view_context, {}) }
  let(:options) do
    [
      {id: 1, title: "Alpha"},
      {id: 2, title: "Beta"},
      {id: 3, title: "Gamma"}
    ]
  end

  def build_field(options:, value: [], inline_search: false)
    described_field = Avo::Fields::CheckboxListField.new(:team_member_ids, name: "Team members", options: options, inline_search: inline_search)
      .hydrate(record:, resource:, view: :edit)

    allow(described_field).to receive(:value).and_return(value)

    described_field
  end

  def render_component(field:, params: {})
    component = described_class.new(field:, resource:, form:)

    if params.present?
      with_request_url("/?#{Rack::Utils.build_nested_query(params)}") do
        render_inline(component)
      end
    else
      render_inline(component)
    end
  end

  it "labels the checkbox group with the field name" do
    render_component(field: build_field(options: options))

    group = page.find(".checkbox-list")

    expect(group["role"]).to eq "group"
    expect(group["aria-label"]).to eq "Team members"
  end

  it "renders rows unchecked with one hidden empty-array marker" do
    render_component(field: build_field(options: options))

    expect(page).to have_css(".checkbox-list__row", count: 3)
    expect(page).to have_css("input[type='hidden'][name='team[team_member_ids][]']", visible: false, count: 1)
    expect(page).to have_css("input[type='checkbox'][name='team[team_member_ids][]']", count: 3)
    expect(page).not_to have_css("input[type='checkbox'][checked]")
  end

  it "does not render inline search by default" do
    render_component(field: build_field(options: options))

    expect(page).not_to have_css("input[type='search']")
    expect(page).not_to have_css("[data-controller='checkbox-list-field']")
  end

  it "renders inline search when enabled" do
    render_component(field: build_field(options: options, inline_search: true))

    input = page.find("input[type='search']#team_team_member_ids_inline_search")
    group = page.find(".checkbox-list")

    expect(group["aria-label"]).to eq "Team members"
    expect(input["placeholder"]).to eq "Search"
    expect(input["name"]).to be_nil
    expect(input["aria-label"]).to eq "Search Team members"
    expect(input["aria-controls"]).to eq group["id"]
    expect(page).to have_css("[data-controller='checkbox-list-field']")
    expect(page).to have_css("[data-checkbox-list-field-target='row']", count: 3)
    expect(page).to have_css("[data-checkbox-list-field-target='empty'][hidden]", text: "No matching options", visible: false)
  end

  it "does not render inline search for empty options" do
    render_component(field: build_field(options: [], inline_search: true))

    expect(page).not_to have_css("input[type='search']")
    expect(page).to have_css(".checkbox-list__empty", text: "No options available")
  end

  it "checks rows that match the field value" do
    render_component(field: build_field(options: options, value: [1, 3]))

    expect(page).to have_checked_field "team_team_member_ids_1"
    expect(page).to have_unchecked_field "team_team_member_ids_2"
    expect(page).to have_checked_field "team_team_member_ids_3"
  end

  it "normalizes string and integer ids when checking rows" do
    render_component(field: build_field(options: options, value: ["1", "3"]))

    expect(page).to have_checked_field "team_team_member_ids_1"
    expect(page).to have_unchecked_field "team_team_member_ids_2"
    expect(page).to have_checked_field "team_team_member_ids_3"
  end

  it "uses submitted params over the stored value after validation errors" do
    render_component(
      field: build_field(options: options, value: [1, 3]),
      params: {"team" => {"team_member_ids" => ["2"]}}
    )

    expect(page).to have_unchecked_field "team_team_member_ids_1"
    expect(page).to have_checked_field "team_team_member_ids_2"
    expect(page).to have_unchecked_field "team_team_member_ids_3"
  end

  it "renders an empty state when no options are available" do
    render_component(field: build_field(options: []))

    expect(page).to have_css(".checkbox-list__empty", text: "No options available")
    expect(page).not_to have_css(".checkbox-list__row")
  end

  it "renders a single option at natural row count" do
    render_component(field: build_field(options: [{id: 1, title: "Only"}]))

    expect(page).to have_css(".checkbox-list__row", count: 1)
  end

  it "renders avatar and description option keys" do
    render_component(field: build_field(options: [
      {
        id: 1,
        title: "Only",
        avatar_url: "https://example.com/avatar.png",
        image_format: "circle",
        description: "Shown",
        badge: "Ignored"
      }
    ]))

    expect(page).to have_css(".checkbox-list__row", text: "Only", count: 1)
    expect(page).to have_css("img.search-item-image.rounded-full[src='https://example.com/avatar.png']")
    expect(page).to have_css(".search-item-description", text: "Shown")
    expect(page).not_to have_text "Ignored"
  end

  it "supports image_url as an avatar alias" do
    render_component(field: build_field(options: [
      {
        id: 1,
        title: "Only",
        image_url: "https://example.com/image.png",
        image_format: "square"
      }
    ]))

    expect(page).to have_css("img.search-item-image.rounded-none[src='https://example.com/image.png']")
  end

  it "evaluates field options once per render" do
    field = build_field(options: options)
    expect(field).to receive(:options).once.and_return(options)

    render_component(field:)
  end
end
