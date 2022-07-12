require "rails_helper"
require "rails/generators"

RSpec.feature "dashboard generator", type: :feature do
  it "generates the files" do
    file = Rails.root.join("app", "avo", "dashboards", "cats.rb").to_s

    Rails::Generators.invoke("avo:dashboard", ["cats", "-q"], {destination_root: Rails.root})

    expect(File.read(file)).to start_with "class Cats < Avo::Dashboards::BaseDashboard"

    check_files_and_clean_up file
  end
end
