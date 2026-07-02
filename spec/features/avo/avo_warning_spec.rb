require "rails_helper"
require "rails/generators"

RSpec.feature "AvoWarning", type: :feature, acquire_lock: :generator do
  before :all do
    Rails::Generators.invoke("avo:resource", ["bad", "--quiet", "--skip"], {destination_root: Rails.root})

    load Rails.root.join("app", "avo", "resources", "bad.rb")
  end

  after :all do
    if defined?(Avo::Resources) && Avo::Resources.const_defined?(:Bad, false)
      Avo::Resources.send(:remove_const, :Bad)
    end

    files = %w[spec/dummy/app/avo/resources/bad.rb spec/dummy/app/controllers/avo/bads_controller.rb]
    files.each do |path|
      File.delete(path) if File.exist?(path)
    end
  end

  it "displays bad model warning" do
    visit "/admin/resources/comments"

    click_on_sidebar_item "Fish"
    expect(page).to have_text "Avo::Resources::Bad does not have a valid model assigned. It failed to find the Bad model."
    expect(page).to have_text "Please create that model or assign one using self.model_class = YOUR_MODEL"
    expect(page).to have_link href: "https://docs.avohq.io/3.0/resources.html#self_model_class"
  end

  it "displays menu editor warning" do
    visit "/admin/resources/comments"

    expect(page).to have_text "The menu editor is available exclusively with the Pro license or above. Consider upgrading to access this feature."
    expect(page).to have_link href: "https://docs.avohq.io/3.0/menu-editor.html"
  end
end
