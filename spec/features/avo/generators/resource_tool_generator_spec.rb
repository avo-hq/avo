require "rails_helper"
require "rails/generators"

RSpec.feature "resource tool generator", type: :feature do
  it "generates the files" do
    files = [
      Rails.root.join("app", "avo", "resource_tools", "cat_tool.rb").to_s,
      Rails.root.join("app", "views", "avo", "resource_tools", "_cat_tool.html.erb").to_s
    ]

    Rails::Generators.invoke("avo:resource_tool", ["cat_tool", "-q"], {destination_root: Rails.root})

    check_files_and_clean_up files
  end
end
