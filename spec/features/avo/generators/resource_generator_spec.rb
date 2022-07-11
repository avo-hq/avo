require "rails_helper"
require "rails/generators"

RSpec.feature "resource generator", type: :feature do
  it "generates the files" do
    files = [
      Rails.root.join("app", "avo", "resources", "kangaroo_resource.rb").to_s,
      Rails.root.join("app", "controllers", "avo", "kangaroos_controller.rb").to_s
    ]

    Rails::Generators.invoke("avo:resource", ["kangaroo", "-q"], {destination_root: Rails.root})

    check_files_and_clean_up files
  end
end
