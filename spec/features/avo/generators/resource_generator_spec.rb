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
      ActiveRecord::Schema.define do
        create_table :test_comments, force: true do |t|
          t.string :commentable_type
          t.integer :commentable_id
          t.text :body
          t.timestamps
        end
      end

      test_model = Class.new(ActiveRecord::Base) do
        self.table_name = :test_comments
        belongs_to :commentable, polymorphic: true
      end

      Object.const_set(:TestComment, test_model)

      files = [
        Rails.root.join("app", "avo", "resources", "test_comment.rb").to_s,
        Rails.root.join("app", "controllers", "avo", "test_comments_controller.rb").to_s
      ]

      Rails::Generators.invoke("avo:resource", ["test_comment", "--quiet", "--skip"], {destination_root: Rails.root})

      generated_content = File.read(files[0])
      expect(generated_content).to include("field :commentable, as: :belongs_to, polymorphic_as: :commentable")

      Object.send(:remove_const, :TestComment)
      ActiveRecord::Base.connection.drop_table(:test_comments)
      check_files_and_clean_up files
    end
  end
end

def keeping_original_files(files)
  # Add _temp to the end of the files name in order to keep the original ones
  files.each do |file_path|
    FileUtils.mv(file_path, "#{file_path}_temp")
  end

  yield

  # Remove the _temp from the end of the files name in order to restore the original ones
  files.each do |file_path|
    FileUtils.mv("#{file_path}_temp", file_path)
  end
end
