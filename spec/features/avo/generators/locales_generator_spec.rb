require "rails_helper"
require "rails/generators"

RSpec.feature "locales generator", type: :feature do
  it "generates the files" do
    # Backup the en locale
    en_locale_backup = Rails.root.join("config", "locales", "avo.en.yml.bak")
    FileUtils.cp(Rails.root.join("config", "locales", "avo.en.yml"), en_locale_backup)

    locales = %w[en fr nn nb pt-BR pt ro tr ar ja es]

    files = locales.map do |locale|
      Rails.root.join("config", "locales", "avo.#{locale}.yml").to_s
    end

    ["nn", "ro"].each do |locale|
      files << Rails.root.join("config", "locales", "pagy", "#{locale}.yml").to_s
    end

    Rails::Generators.invoke("avo:locales", ["-q"], {destination_root: Rails.root})

    check_files_and_clean_up files

    # Restore the en locale
    FileUtils.mv(en_locale_backup, Rails.root.join("config", "locales", "avo.en.yml"))
  end
end
