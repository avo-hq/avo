require "rails_helper"
require "rails/generators"

RSpec.feature "cards generator", type: :feature do
  describe "partial" do
    it "generates the files" do
      files = [
        Rails.root.join("app", "avo", "cards", "partial_custom_for_spec.rb").to_s,
        Rails.root.join("app", "views", "avo", "cards", "_partial_custom_for_spec.html.erb").to_s
      ]

      Rails::Generators.invoke("avo:card", ["partial_custom_for_spec", "--type", "partial", "-q"], {destination_root: Rails.root})

      expect(File.read(files.first)).to include "class Avo::Cards::PartialCustomForSpec < Avo::Dashboards::PartialCard"
      expect(File.read(files.second)).to include "Customize this partial under <code class='p-1 rounded bg-gray-500 text-white text-sm'>app/views/avo/cards/_partial_custom_for_spec.html.erb</code>"

      check_files_and_clean_up files
    end
  end

  describe "metric" do
    it "generates the files" do
      file = Rails.root.join("app", "avo", "cards", "metric_card_for_spec.rb").to_s

      Rails::Generators.invoke("avo:card", ["metric_card_for_spec", "--type", "metric", "-q"], {destination_root: Rails.root})

      expect(File.read(file)).to include "class Avo::Cards::MetricCardForSpec < Avo::Dashboards::MetricCard"

      check_files_and_clean_up file
    end
  end

  describe "chartkick" do
    it "generates the files" do
      file = Rails.root.join("app", "avo", "cards", "chartkick_card_for_spec.rb").to_s

      Rails::Generators.invoke("avo:card", ["chartkick_card_for_spec", "--type", "chartkick", "-q"], {destination_root: Rails.root})

      expect(File.read(file)).to include "class Avo::Cards::ChartkickCardForSpec < Avo::Dashboards::ChartkickCard"

      check_files_and_clean_up file
    end
  end
end
