require "rails_helper"

RSpec.describe Avo::TabHeaderComponent, type: :component do
  let(:title) { "Sample Title" }
  let(:description) { "Sample Description" }

  describe "rendering" do
    context "when both title and description are present" do
      it "renders the title and description" do
        render_inline(described_class.new(title: title, description: description))

        expect(rendered_content).to have_content(title)
        expect(rendered_content).to have_content(description)
      end
    end

    context "when title is absent" do
      let(:title) { nil }

      it "renders only the description" do
        render_inline(described_class.new(title: title, description: description))

        expect(rendered_content).to have_content(description)
        expect(rendered_content).not_to have_content("Sample Title")
      end
    end

    context "when description is absent" do
      let(:description) { nil }

      it "renders only the title" do
        render_inline(described_class.new(title: title, description: description))

        expect(rendered_content).to have_content(title)
        expect(rendered_content).not_to have_content("Sample Description")
      end
    end

    context "when both title and description are absent" do
      let(:title) { nil }
      let(:description) { nil }

      it "renders nothing" do
        render_inline(described_class.new(title: title, description: description))

        expect(rendered_content).to be_blank
      end
    end
  end
end
