require "rails_helper"

RSpec.describe Avo::CoverPhotoComponent, type: :component do
  let(:cover_photo) { double("cover_photo") }
  let(:resource) { double("resource", cover_photo: cover_photo) }

  describe "rendering" do
    context "when cover photo is present and visible in the current view" do
      before do
        allow(cover_photo).to receive(:present?).and_return(true)
        allow(cover_photo).to receive(:visible_in_current_view?).and_return(true)
        allow(cover_photo).to receive(:value).and_return("cover_photo_value")
        allow(cover_photo).to receive(:size).and_return(:md)
      end

      it "renders the component with the correct size and visibility settings" do
        render_inline(described_class.new(cover_photo: cover_photo))

        expect(rendered_component).to have_css(".aspect-cover-md")
        expect(rendered_component).to have_selector("img[src='cover_photo_value']")
      end
    end

    context "when cover photo is not present" do
      before do
        allow(cover_photo).to receive(:present?).and_return(false)
      end

      it "does not render the component" do
        render_inline(described_class.new(cover_photo: cover_photo))

        expect(rendered_component).to be_blank
      end
    end

    context "when cover photo is not visible in the current view" do
      before do
        allow(cover_photo).to receive(:visible_in_current_view?).and_return(false)
      end

      it "does not render the component" do
        render_inline(described_class.new(cover_photo: cover_photo))

        expect(rendered_component).to be_blank
      end
    end

    context "when cover photo source is a lambda" do
      let(:lambda_source) { -> { "dynamic_source_value" } }

      before do
        allow(cover_photo).to receive(:present?).and_return(true)
        allow(cover_photo).to receive(:visible_in_current_view?).and_return(true)
        allow(cover_photo).to receive(:value).and_return(lambda_source.call)
      end

      it "correctly handles dynamic sources" do
        render_inline(described_class.new(cover_photo: cover_photo))

        expect(rendered_component).to have_selector("img[src='dynamic_source_value']")
      end
    end
  end
end
