require "rails_helper"
require "rails/generators"

RSpec.feature "field generator", type: :feature do
  it "generates the files" do
    file = Rails.root.join("app", "avo", "fields", "cats_field.rb").to_s
    components = [
      Rails.root.join("app", "components", "avo", "fields", "cats_field", "edit_component.rb").to_s,
      Rails.root.join("app", "components", "avo", "fields", "cats_field", "edit_component.html.erb").to_s,
      Rails.root.join("app", "components", "avo", "fields", "cats_field", "index_component.rb").to_s,
      Rails.root.join("app", "components", "avo", "fields", "cats_field", "index_component.html.erb").to_s,
      Rails.root.join("app", "components", "avo", "fields", "cats_field", "show_component.rb").to_s,
      Rails.root.join("app", "components", "avo", "fields", "cats_field", "show_component.html.erb").to_s,
    ]

    Rails::Generators.invoke("avo:field", ["cats", "-q"], {destination_root: Rails.root})

    expect(File.read(file)).to start_with "class Avo::Fields::CatsField < Avo::Fields::BaseField"

    check_files_and_clean_up file

    check_files_and_clean_up components
  end
end
