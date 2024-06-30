require "rails_helper"

RSpec.describe Avo::ProfilePhotoComponent, type: :component do
  let(:profile_photo) { double("profile_photo") }
  let(:resource) { double("resource", profile_photo: profile_photo) }

  describe "rendering" do
    context "when profile photo is present and visible in the current view" do
      before do
        allow(profile_photo).to receive(:present?).and_return(true)
        allow(profile_photo).to receive(:visible_in_current_view?).and_return(true)
        allow(profile_photo).to receive(:value).and_return("profile_photo_value")
      end

      it "renders the component with the correct visibility settings" do
        render_inline(described_class.new(profile_photo: profile_photo))

        expect(rendered_component).to have_selector("img[src='profile_photo_value']")
      end
    end

    context "when profile photo is not present" do
      before do
        allow(profile_photo).to receive(:present?).and_return(false)
      end

      it "does not render the component" do
        render_inline(described_class.new(profile_photo: profile_photo))

        expect(rendered_component).to be_blank
      end
    end

    context "when profile photo is not visible in the current view" do
      before do
        allow(profile_photo).to receive(:visible_in_current_view?).and_return(false)
      end

      it "does not render the component" do
        render_inline(described_class.new(profile_photo: profile_photo))

        expect(rendered_component).to be_blank
      end
    end

    context "when profile photo source is a lambda" do
      let(:lambda_source) { -> { "dynamic_source_value" } }

      before do
        allow(profile_photo).to receive(:present?).and_return(true)
        allow(profile_photo).to receive(:visible_in_current_view?).and_return(true)
        allow(profile_photo).to receive(:value).and_return(lambda_source.call)
      end

      it "correctly handles dynamic sources" do
        render_inline(described_class.new(profile_photo: profile_photo))

        expect(rendered_component).to have_selector("img[src='dynamic_source_value']")
      end
    end
  end
end
