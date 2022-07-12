require "rails_helper"
require "rails/generators"

RSpec.feature "controller generator", type: :feature do
  it "generates the files" do
    file = Rails.root.join("app", "controllers", "avo", "cats_controller.rb").to_s

    Rails::Generators.invoke("avo:controller", ["cats", "-q"], {destination_root: Rails.root})

    check_files_and_clean_up file
  end
end
