require "rails_helper"
require "rails/generators"

RSpec.feature "filter generator", type: :feature do
  describe "without a type" do
    it "generates the files" do
      filter = Rails.root.join("app", "avo", "filters", "cats.rb").to_s

      Rails::Generators.invoke("avo:filter", ["cats", "-q"], {destination_root: Rails.root})

      expect(File.read(filter)).to start_with "class Avo::Filters::Cats < Avo::Filters::BooleanFilter"

      check_files_and_clean_up filter
    end
  end

  describe "boolean type" do
    it "generates the files" do
      filter = Rails.root.join("app", "avo", "filters", "cats.rb").to_s

      Rails::Generators.invoke("avo:filter", ["cats", "--type", "boolean", "-q"], {destination_root: Rails.root})

      expect(File.read(filter)).to start_with "class Avo::Filters::Cats < Avo::Filters::BooleanFilter"

      check_files_and_clean_up filter
    end
  end

  describe "select type" do
    it "generates the files" do
      filter = Rails.root.join("app", "avo", "filters", "cats.rb").to_s

      Rails::Generators.invoke("avo:filter", ["cats", "--type", "select", "-q"], {destination_root: Rails.root})

      expect(File.read(filter)).to start_with "class Avo::Filters::Cats < Avo::Filters::SelectFilter"

      check_files_and_clean_up filter
    end
  end

  describe "text type" do
    it "generates the files" do
      filter = Rails.root.join("app", "avo", "filters", "cats.rb").to_s

      Rails::Generators.invoke("avo:filter", ["cats", "--type", "text", "-q"], {destination_root: Rails.root})

      expect(File.read(filter)).to start_with "class Avo::Filters::Cats < Avo::Filters::TextFilter"

      check_files_and_clean_up filter
    end
  end

  describe "multiple select type" do
    it "generates the files" do
      filter = Rails.root.join("app", "avo", "filters", "cats.rb").to_s

      Rails::Generators.invoke("avo:filter", ["cats", "--type", "multiple_select", "-q"], {destination_root: Rails.root})

      expect(File.read(filter)).to start_with "class Avo::Filters::Cats < Avo::Filters::MultipleSelectFilter"

      check_files_and_clean_up filter
    end
  end
end
