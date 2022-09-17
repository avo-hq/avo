require "rails_helper"
require "rails/generators"

RSpec.feature "filter generator", type: :feature do
  describe "without a type" do
    it "generates the files" do
      filter = Rails.root.join("app", "avo", "filters", "cats.rb").to_s

      Rails::Generators.invoke("avo:filter", ["cats", "-q"], {destination_root: Rails.root})

      expect(File.read(filter)).to start_with "class Cats < Avo::Filters::BooleanFilter"

      check_files_and_clean_up filter
    end
  end

  describe "boolean type" do
    it "generates the files" do
      filter = Rails.root.join("app", "avo", "filters", "cats.rb").to_s

      Rails::Generators.invoke("avo:filter", ["cats", "--boolean", "-q"], {destination_root: Rails.root})

      expect(File.read(filter)).to start_with "class Cats < Avo::Filters::BooleanFilter"

      check_files_and_clean_up filter
    end
  end

  describe "select type" do
    it "generates the files" do
      filter = Rails.root.join("app", "avo", "filters", "cats.rb").to_s

      Rails::Generators.invoke("avo:filter", ["cats", "--select", "-q"], {destination_root: Rails.root})

      expect(File.read(filter)).to start_with "class Cats < Avo::Filters::SelectFilter"

      check_files_and_clean_up filter
    end
  end

  describe "text type" do
    it "generates the files" do
      filter = Rails.root.join("app", "avo", "filters", "cats.rb").to_s

      Rails::Generators.invoke("avo:filter", ["cats", "--text", "-q"], {destination_root: Rails.root})

      expect(File.read(filter)).to start_with "class Cats < Avo::Filters::TextFilter"

      check_files_and_clean_up filter
    end
  end

  describe "multiple select type" do
    it "generates the files" do
      filter = Rails.root.join("app", "avo", "filters", "cats.rb").to_s

      Rails::Generators.invoke("avo:filter", ["cats", "--multiple_select", "-q"], {destination_root: Rails.root})

      expect(File.read(filter)).to start_with "class Cats < Avo::Filters::MultipleSelectFilter"

      check_files_and_clean_up filter
    end
  end
end
