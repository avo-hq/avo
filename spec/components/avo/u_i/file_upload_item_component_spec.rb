require "rails_helper"

RSpec.describe Avo::UI::FileUploadItemComponent, type: :component do
  describe "rendering" do
    it "renders default state with title and size" do
      render_inline(described_class.new(title: "image.png", size_label: "200KB"))

      expect(page).to have_css(".file-upload-item")
      expect(page).to have_text("image.png")
      expect(page).to have_text("200KB")
    end

    it "renders complete status when state is complete (progress or state triggers display)" do
      render_inline(described_class.new(
        title: "image.png",
        size_label: "200KB",
        state: :complete,
        progress: 0
      ))

      expect(page).to have_css(".file-upload-item__status--complete")
      expect(page).to have_text("Complete")
    end

    it "renders uploading progress indicator when state is uploading and progress > 0" do
      render_inline(described_class.new(
        title: "image.png",
        size_label: "200KB",
        state: :uploading,
        progress: 75
      ))

      expect(page).to have_css(".file-upload-item--uploading")
      expect(page).to have_css(".file-upload-item__progress[style*='75%']")
      expect(page).to have_text("75%")
    end

    it "renders error status when state is error" do
      render_inline(described_class.new(
        title: "image.png",
        size_label: "200KB",
        state: :error,
        progress: 0
      ))

      expect(page).to have_css(".file-upload-item__status--error")
      expect(page).to have_text("Try again")
    end

    it "renders error status when state is failed" do
      render_inline(described_class.new(
        title: "image.png",
        size_label: "200KB",
        state: :failed,
        progress: 0
      ))

      expect(page).to have_css(".file-upload-item__status--error")
      expect(page).to have_text("Try again")
    end

    it "does not render status when state is default" do
      render_inline(described_class.new(
        title: "image.png",
        size_label: "200KB",
        state: :default,
        progress: 50
      ))

      expect(page).not_to have_css(".file-upload-item__status--complete")
      expect(page).not_to have_css(".file-upload-item__status--error")
      expect(page).not_to have_css(".file-upload-item__status--uploading")
    end

    it "renders block content in actions area" do
      render_inline(described_class.new(title: "image.png", size_label: "200KB")) do
        "Custom actions"
      end

      expect(page).to have_css(".file-upload-item__actions")
      expect(page).to have_text("Custom actions")
    end
  end

  describe "progress" do
    it "clamps progress to 0-100 range" do
      component = described_class.new(
        title: "image.png",
        size_label: "200KB",
        progress: 150
      )

      expect(component.progress_percentage).to eq(100)
    end

    it "handles negative progress" do
      component = described_class.new(
        title: "image.png",
        size_label: "200KB",
        progress: -10
      )

      expect(component.progress_percentage).to eq(0)
    end
  end
end
