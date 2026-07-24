require "rails_helper"

RSpec.feature "HtmlAttributes", type: :feature do
  let(:product) { create :product }
  let(:label) { field_wrapper(:title).find('[data-slot="label"]') }
  let(:content) { field_wrapper(:title).find('[data-slot="value"]') }

  context "on show" do
    before { visit avo.resources_product_path product }

    it "renders the html attributes" do
      expect(content[:class]).to include "bg-gray-50 !text-pink-600"
      expect(label[:class]).to include "bg-gray-50 !text-pink-600"
    end

    it "renders the style attribute on the label and content elements" do
      expect(label[:style]).to include "letter-spacing: 0.5px"
      expect(content[:style]).to include "letter-spacing: 1px"
    end

    it "renders the data attributes on the label and content elements" do
      expect(label["data-show-label-marker"]).to eq "title"
      expect(content["data-show-content-marker"]).to eq "title"
    end

    it "keeps the slot data attributes when the field declares its own data" do
      expect(label["data-slot"]).to eq "label"
      expect(content["data-slot"]).to eq "value"
    end

    it "renders no style attribute for a field without html options" do
      expect(field_wrapper(:price).find('[data-slot="label"]')[:style]).to be_blank
      expect(field_wrapper(:price).find('[data-slot="value"]')[:style]).to be_blank
    end
  end

  context "on edit" do
    before { visit avo.edit_resources_product_path product }

    it "renders the classes, style and data attributes on the label element" do
      expect(label[:class]).to include "bg-gray-100 !text-blue-600"
      expect(label[:style]).to include "letter-spacing: 1.5px"
      expect(label["data-edit-label-marker"]).to eq "title"
      expect(label["data-slot"]).to eq "label"
    end

    it "renders the classes, style and data attributes on the content element" do
      expect(content[:class]).to include "bg-gray-100 !text-blue-600"
      expect(content[:style]).to include "letter-spacing: 2px"
      expect(content["data-edit-content-marker"]).to eq "title"
      expect(content["data-slot"]).to eq "value"
    end
  end

  context "on index" do
    let(:red_team) { create :team, color: "#FF0000" }
    let(:green_team) { create :team, color: "#00FF00" }
    let(:user) { create :user }

    before do
      # Only teams with members show on index page
      [red_team, green_team].each do |team|
        team.team_members << user
      end
    end

    it "evaluates the block syntax" do
      visit avo.resources_teams_path

      expect(field_element_by_resource_id("name", red_team.id)["style"]).to match(/color: #FF0000/)
      expect(field_element_by_resource_id("name", green_team.id)["style"]).to match(/color: #00FF00/)
    end
  end

  context "with the block notation on show" do
    let(:team) { create :team, color: "#FF0000" }

    before { visit avo.resources_team_path team }

    it "evaluates the block syntax for the label and content elements" do
      label = field_wrapper(:name).find('[data-slot="label"]')
      content = field_wrapper(:name).find('[data-slot="value"]')

      expect(label[:style]).to match(/color: #FF0000/)
      expect(label["data-block-label-marker"]).to eq "name"
      expect(content[:style]).to match(/color: #FF0000/)
      expect(content["data-block-content-marker"]).to eq "name"
    end
  end
end
