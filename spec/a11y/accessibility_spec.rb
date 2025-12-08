require "rails_helper"
require "axe-rspec"

RSpec.describe "Accessibility", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1024]
  end

  context "when accessing resource index" do
    Avo::Resources::ResourceManager.fetch_resources.each do |resource|
      it "has no accessibility violations for #{resource.name}" do
        visit avo.send("resources_#{resource.route_key}_path")

        expect(page).to be_axe_clean
      end
    end
  end
end
