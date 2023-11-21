require "rails_helper"
require "rails/generators"

RSpec.feature "resource generator", type: :feature do
  it "generates the files" do
    files = [
      Rails.root.join("app", "avo", "resources", "kangaroo.rb").to_s,
      Rails.root.join("app", "controllers", "avo", "kangaroos_controller.rb").to_s
    ]

    Rails::Generators.invoke("avo:resource", ["kangaroo", "--quiet", "--skip"], {destination_root: Rails.root})

    check_files_and_clean_up files
  end

  context "when generating resources from a DB model" do
    it "generates with the correct date_time field type" do
      files = [
        Rails.root.join("app", "avo", "resources", "event.rb").to_s,
        Rails.root.join("app", "controllers", "avo", "events_controller.rb").to_s
      ]

      Rails::Generators.invoke("avo:resource", ["event", "-q"], {destination_root: Rails.root})

      expect(File.read(files[0])).to include("field :event_time, as: :date_time")

      check_files_and_clean_up files
    end
  end

  context "when generating resources from a rich texts" do
    it "generates with the correct trix field type" do
      files = [
        Rails.root.join("app", "avo", "resources", "event.rb").to_s,
        Rails.root.join("app", "controllers", "avo", "events_controller.rb").to_s
      ]

      Rails::Generators.invoke("avo:resource", ["event", "-q"], {destination_root: Rails.root})

      expect(File.read(files[0])).to include("field :body, as: :trix")

      check_files_and_clean_up files
    end
  end
end
