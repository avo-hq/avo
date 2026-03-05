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

      keeping_original_files(files) do
        Rails::Generators.invoke("avo:resource", ["event", "-q"], {destination_root: Rails.root})

        expect(File.read(files[0])).to include("field :event_time, as: :date_time")

        check_files_and_clean_up files
      end
    end
  end

  context "when generating resources from a rich texts" do
    it "generates with the correct trix field type" do
      files = [
        Rails.root.join("app", "avo", "resources", "event.rb").to_s,
        Rails.root.join("app", "controllers", "avo", "events_controller.rb").to_s
      ]

      keeping_original_files(files) do
        Rails::Generators.invoke("avo:resource", ["event", "-q"], {destination_root: Rails.root})

        expect(File.read(files[0])).to include("field :body, as: :trix")

        check_files_and_clean_up files
      end
    end
  end

  context "when generating resources with polymorphic associations" do
    it "generates commented polymorphic fields" do
      files = [
        Rails.root.join("app", "avo", "resources", "review.rb").to_s,
        Rails.root.join("app", "controllers", "avo", "reviews_controller.rb").to_s
      ]

      keeping_original_files(files) do
        Rails::Generators.invoke("avo:resource", ["review", "-q", "-s"], {destination_root: Rails.root})

        # Types load in different order every time
        expect(File.read(files[0])).to include("field :reviewable, as: :belongs_to, polymorphic_as: :reviewable, types:")
        expect(File.read(files[0])).to include("Team")
        expect(File.read(files[0])).to include("Project")
        expect(File.read(files[0])).to include("Post")
        expect(File.read(files[0])).to include("Fish")

        check_files_and_clean_up files
      end
    end
  end

  context "when predicting menu icons" do
    around do |example|
      previous_value = Avo.configuration.predict_menu_item
      example.run
      Avo.configuration.predict_menu_item = previous_value
    end

    it "uses ICON_MAP when prediction is disabled" do
      files = [
        Rails.root.join("app", "avo", "resources", "transaction.rb").to_s,
        Rails.root.join("app", "controllers", "avo", "transactions_controller.rb").to_s
      ]

      Avo.configuration.predict_menu_item = false
      files.each { |file| FileUtils.rm_f(file) }

      Rails::Generators.invoke("avo:resource", ["transaction", "--quiet", "--skip"], {destination_root: Rails.root})

      expect(File.read(files[0])).to include('self.icon = "tabler/outline/credit-card-pay"')

      check_files_and_clean_up files
    end

    it "uses a predicted tabler icon when enabled" do
      files = [
        Rails.root.join("app", "avo", "resources", "home.rb").to_s,
        Rails.root.join("app", "controllers", "avo", "homes_controller.rb").to_s
      ]

      Avo.configuration.predict_menu_item = true
      files.each { |file| FileUtils.rm_f(file) }

      Rails::Generators.invoke("avo:resource", ["home", "--quiet", "--skip"], {destination_root: Rails.root})

      expect(File.read(files[0])).to include('self.icon = "tabler/outline/home"')

      check_files_and_clean_up files
    end

    it "falls back to ICON_MAP when prediction has no confident match" do
      files = [
        Rails.root.join("app", "avo", "resources", "transaction.rb").to_s,
        Rails.root.join("app", "controllers", "avo", "transactions_controller.rb").to_s
      ]

      Avo.configuration.predict_menu_item = true
      files.each { |file| FileUtils.rm_f(file) }
      allow(Dir).to receive(:glob).and_call_original
      allow(Dir).to receive(:glob).with(a_string_including("tabler/outline/*.svg")).and_return([])

      Rails::Generators.invoke("avo:resource", ["transaction", "--quiet", "--skip"], {destination_root: Rails.root})

      expect(File.read(files[0])).to include('self.icon = "tabler/outline/credit-card-pay"')

      check_files_and_clean_up files
    end
  end
end

def keeping_original_files(files)
  # Add _temp to the end of the files name in order to keep the original ones
  files.each do |file_path|
    FileUtils.mv(file_path, "#{file_path}_temp")
  end

  begin
    yield
  ensure
    # Remove the _temp from the end of the files name in order to restore the original ones
    files.each do |file_path|
      FileUtils.mv("#{file_path}_temp", file_path)
    end
  end
end
