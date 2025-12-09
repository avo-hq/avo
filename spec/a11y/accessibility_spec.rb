require "rails_helper"

# DOCS according_to: https://github.com/dequelabs/axe-core/blob/master/doc/API.md#options-parameter

RSpec.describe "Accessibility", type: :system, a11y: true do
  # context "when accessing resource index" do
  # Avo::Resources::ResourceManager.fetch_resources.each do |resource|
  #   it "has no accessibility violations for #{resource.name}" do
  #     visit avo.send(:"resources_#{resource.route_key}_path")

  #     expect(page).to be_axe_clean.according_to :wcag21aa, :section508
  #   end
  # end
  # end

  # context "UI components" do
  #   it "discreet information" do
  #     visit "/admin/lookbook/inspect/discreet_information/default"
  #     expect(page).to be_axe_clean.according_to :wcag21aa, :section508
  #   end

  #   it "button" do
  #     visit "/admin/lookbook/inspect/button/standard"
  #     expect(page).to be_axe_clean.according_to :wcag21aa, :section508
  #   end

  #   it "avatar" do
  #     visit "/admin/lookbook/inspect/avatar/types"
  #     expect(page).to be_axe_clean.according_to :wcag21aa, :section508

  #     visit "/admin/lookbook/inspect/avatar/standard_examples"
  #     expect(page).to be_axe_clean.according_to :wcag21aa, :section508
  #   end
  # end

  context "Lookbook previews" do
    Lookbook.previews.each do |preview|
      preview.scenarios.each do |scenario|
        it "#{preview.name}/#{scenario.name} is accessible" do
          visit "/admin/lookbook/inspect/#{preview.name}/#{scenario.name}"
          expect(page).to be_axe_clean.according_to :wcag22aa
        end
      end
    end
  end
end
