require "rails_helper"

RSpec.describe Avo::FieldWrapperComponent, type: :component do
  let(:record) { Product.new }
  let(:resource) { Avo::Resources::Product.new(record:, view: :edit) }
  let(:field) do
    Avo::Fields::TiptapField.new(:description)
      .hydrate(record:, resource:, view: :edit)
  end

  it "adds the shared resizable editor contract on form views" do
    render_inline(described_class.new(
      field:,
      resource:,
      view: Avo::ViewInquirer.new(:edit),
      data: {controller: "custom-controller"}
    )) { "Editor" }

    wrapper = page.find("[data-field-id='description']")

    expect(wrapper["data-controller"].split).to contain_exactly("custom-controller", "resizable-editor")
    expect(wrapper["data-resizable-editor-target-selector-value"]).to eq(".tiptap.ProseMirror")
    expect(wrapper["data-resizable-editor-storage-key-value"]).to eq("resources.products.fields.description.height")
  end

  it "lets a field-level `stacked: false` win over the component default" do
    field = Avo::Fields::TextField.new(:name, stacked: false)
      .hydrate(record:, resource:, view: :show)

    # `stacked: true` is what the sidebar and preview components pass in.
    render_inline(described_class.new(field:, resource:, stacked: true)) { "Name" }

    expect(page.find("[data-field-id='name']")[:class]).not_to include("field-wrapper--stacked")
  end

  it "does not resize rich text rendered on display views" do
    render_inline(described_class.new(
      field:,
      resource:,
      view: Avo::ViewInquirer.new(:show)
    )) { "Content" }

    wrapper = page.find("[data-field-id='description']")

    expect(wrapper["data-controller"]).to be_nil
    expect(wrapper["data-resizable-editor-target-selector-value"]).to be_nil
  end

  describe "tooltips" do
    let(:record) { Project.new(name: "Apollo", stage: "Done") }
    let(:resource) { Avo::Resources::Project.new(record:, view: :show) }
    let(:show_view) { Avo::ViewInquirer.new(:show) }
    let(:badge) do
      Avo::Fields::BadgeField.new(:stage, tooltip: "Done since 2026-09-23", label_tooltip: "Lifecycle state")
        .hydrate(record:, resource:, view: :show)
    end

    it "anchors the value tooltip to the value, not the row" do
      render_inline(described_class.new(field: badge, resource:, view: show_view)) { "Done" }

      anchor = page.find(".field-wrapper__content .tooltip-anchor")

      expect(anchor[:title]).to eq "Done since 2026-09-23"
      expect(anchor["data-tippy"]).to eq "tooltip"
      expect(anchor[:class]).to include("tooltip-anchor--inline")
      expect(anchor).to have_text "Done"
    end

    it "keeps the copy button outside the value anchor" do
      field = Avo::Fields::TextField.new(:name, tooltip: "Shown on the invoice", copyable: true)
        .hydrate(record:, resource:, view: :show)

      render_inline(described_class.new(field:, resource:, view: show_view)) { "Apollo" }

      expect(page).to have_css("[data-controller='clipboard']")
      expect(page).not_to have_css(".tooltip-anchor [data-controller='clipboard']")
    end

    it "puts the label tooltip and its cue on the label" do
      render_inline(described_class.new(field: badge, resource:, view: show_view)) { "Done" }

      label = page.find(".field-wrapper__label .label-tooltip")

      expect(label[:title]).to eq "Lifecycle state"
      expect(label["data-tippy"]).to eq "tooltip"
      expect(label).to have_text "Stage"
      expect(label).to have_css("svg.label-tooltip__icon")
    end

    it "anchors the value tooltip to the input on forms" do
      field = Avo::Fields::TextField.new(:name, tooltip: "Shown on the invoice")
        .hydrate(record:, resource:, view: :edit)

      render_inline(described_class.new(field:, resource:, view: Avo::ViewInquirer.new(:edit))) { "Input" }

      input = page.find(".field-wrapper__input")

      expect(input[:title]).to eq "Shown on the invoice"
      expect(input["data-tippy"]).to eq "tooltip"
      expect(page).not_to have_css(".tooltip-anchor")
    end

    it "widens the anchor for values that fill the row" do
      field = Avo::Fields::CodeField.new(:body, tooltip: "Raw HTML")
        .hydrate(record:, resource:, view: :show)

      render_inline(described_class.new(field:, resource:, view: show_view)) { "<html>" }

      expect(page.find(".tooltip-anchor")[:class]).to include("tooltip-anchor--block")
    end

    it "widens the anchor around collapsable content" do
      field = Avo::Fields::TextField.new(:name, tooltip: "Long form")
        .hydrate(record:, resource:, view: :show)

      render_inline(described_class.new(field:, resource:, view: show_view, collapsable: true)) { "Apollo" }

      expect(page.find(".tooltip-anchor")[:class]).to include("tooltip-anchor--block")
    end

    it "renders no anchor and no cue without tooltips" do
      field = Avo::Fields::TextField.new(:name).hydrate(record:, resource:, view: :show)

      render_inline(described_class.new(field:, resource:, view: show_view)) { "Apollo" }

      expect(page).not_to have_css(".tooltip-anchor")
      expect(page).not_to have_css("[data-tippy]")
      expect(page).not_to have_css(".label-tooltip__icon")
    end

    it "resolves tooltip blocks with the field's context" do
      field = Avo::Fields::TextField.new(:name,
        tooltip: -> { "#{record.class.name} #{field.id} on #{view}" },
        label_tooltip: -> { "#{resource.route_key} table" })
        .hydrate(record:, resource:, view: :show)

      render_inline(described_class.new(field:, resource:, view: show_view)) { "Apollo" }

      expect(page.find(".tooltip-anchor")[:title]).to eq "Project name on show"
      expect(page.find(".label-tooltip")[:title]).to eq "projects table"
    end
  end
end
