require "rails_helper"

# DOCS according_to: https://github.com/dequelabs/axe-core/blob/master/doc/API.md#options-parameter

RSpec.describe "Accessibility", type: :system, a11y: true do
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
