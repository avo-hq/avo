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
end
