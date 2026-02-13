require "rails_helper"

RSpec.describe Avo::UI::FileUploadInputComponent, type: :component do
  describe "rendering" do
    it "renders default variant classes" do
      render_inline(described_class.new(id: "test"))

      expect(page).to have_css(".file-upload-input.file-upload-input--lg")
      expect(page).to have_text("Click to upload")
      expect(page).to have_text("or drag and drop")
    end

    it "renders sm variant without text content" do
      render_inline(described_class.new(id: "test", size: :sm))

      expect(page).to have_css(".file-upload-input.file-upload-input--sm")
      expect(page).not_to have_css(".file-upload-input__content")
    end

    it "renders md variant with text content" do
      render_inline(described_class.new(id: "test", size: :md))

      expect(page).to have_css(".file-upload-input.file-upload-input--md")
      expect(page).to have_css(".file-upload-input__content")
    end

    it "renders disabled state class" do
      render_inline(described_class.new(id: "test", disabled: true))

      expect(page).to have_css(".file-upload-input--disabled")
    end
  end

  describe "normalization" do
    it "falls back to lg size for invalid value" do
      render_inline(described_class.new(id: "test", size: :invalid))

      expect(page).to have_css(".file-upload-input--lg")
      expect(page).not_to have_css(".file-upload-input--invalid")
    end
  end
end
