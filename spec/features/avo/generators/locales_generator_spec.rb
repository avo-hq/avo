require "rails_helper"
require "rails/generators"

RSpec.feature "locales generator", type: :feature do
  it "generates the files" do
    # Define locales to backup
    backup_locales = %w[en pt]

    # Backup locales
    backup_files = {}
    backup_locales.each do |locale|
      original_file = Rails.root.join("config", "locales", "avo.#{locale}.yml")
      backup_file = Rails.root.join("config", "locales", "avo.#{locale}.yml.bak")
      FileUtils.cp(original_file, backup_file) if File.exist?(original_file)
      backup_files[locale] = {original: original_file, backup: backup_file}
    end

    locales = %w[ar de en es fr it ja nb nl nn pl pt-BR pt ro ru tr uk zh]

    files = locales.map do |locale|
      Rails.root.join("config", "locales", "avo.#{locale}.yml").to_s
    end

    ["nn", "ro"].each do |locale|
      files << Rails.root.join("config", "locales", "pagy", "#{locale}.yml").to_s
    end

    Rails::Generators.invoke("avo:locales", ["-q"], {destination_root: Rails.root})

    check_files_and_clean_up files

    # Restore locales from backup
    backup_files.each do |locale, paths|
      FileUtils.mv(paths[:backup], paths[:original]) if File.exist?(paths[:backup])
    end
  end
end
