require "rails_helper"
require "rails/generators"

RSpec.feature "ResourceMissingModels", type: :feature do
  before :all do
    Rails::Generators.invoke("avo:resource", ["bad", "--quiet", "--skip"], {destination_root: Rails.root})
  end

  after :all do
    files = %w[spec/dummy/app/avo/resources/bad_resource.rb spec/dummy/app/controllers/avo/bads_controller.rb]
    files.each do |path|
      File.delete(path) if File.exist?(path)
    end
  end

  it "tests the message" do
    visit "/admin/resources/comments"

    click_on_sidebar_item "Fish"
    expect(page).to have_text "Avo::Resources::Bad does not have a valid model assigned. It failed to find the Bad model."
    expect(page).to have_text "Please create that model or assign one using self.model_class = YOUR_MODEL"
    expect(page).to have_link href: "https://docs.avohq.io/2.0/resources.html#custom-model-class"
  end
end
