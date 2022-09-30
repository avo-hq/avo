require "rails_helper"
require "rails/generators"

RSpec.feature "locales generator", type: :feature do
  it "generates the files" do
    locales = %w[en fr nn nb pt-BR ro tr]

    files = locales.map do |locale|
      Rails.root.join("config", "locales", "avo.#{locale}.yml").to_s
    end

    Rails::Generators.invoke("avo:locales", ["-q"], {destination_root: Rails.root})

    check_files_and_clean_up files
  end
end
