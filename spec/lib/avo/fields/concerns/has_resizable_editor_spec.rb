require "rails_helper"

RSpec.describe Avo::Fields::Concerns::HasResizableEditor do
  it "is disabled for regular fields" do
    field = Avo::Fields::TextField.new(:body)

    expect(field).not_to be_resizable_editor
    expect(field.resizable_editor_target_selector).to be_nil
  end

  it "configures the editable viewport for the built-in rich text fields" do
    expect(Avo::Fields::TiptapField.new(:body).resizable_editor_target_selector).to eq(".tiptap.ProseMirror")
    expect(Avo::Fields::TrixField.new(:body).resizable_editor_target_selector).to eq("trix-editor.trix-content")
  end

  it "provides an inheritable opt-in for custom editor fields" do
    custom_field_class = Class.new(Avo::Fields::BaseField) do
      resizable_editor target: ".custom-editor__content"
    end
    inherited_field_class = Class.new(custom_field_class)

    expect(custom_field_class.new(:body)).to be_resizable_editor
    expect(inherited_field_class.new(:body).resizable_editor_target_selector).to eq(".custom-editor__content")
  end
end
