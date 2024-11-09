desc "Compares the en avo translation keys with the other locales and reports missing keys"
task "avo:i18n:missing_translations" => :environment do
  # Nothing to compare if there's only one locale
  return if I18n.available_locales.size <= 1

  # This locale is considered the reference as to what keys should exist
  locale_to_compare_to = :en

  # Ensure translations are loaded
  I18n.backend.send(:init_translations)

  # Get all translations
  translations = I18n.backend.send(:translations)

  # Helper method to collect all translation keys in in a given scope
  def collect_translation_keys(scope, translations)
    translations.map do |key, translations|
      new_scope = scope + [key]
      if translations.is_a?(Hash)
        collect_translation_keys(new_scope, translations)
      else
        new_scope.join(".")
      end
    end.flatten
  end

  # Collect all avo translation keys in the reference locale
  reference_keys = collect_translation_keys([], translations[locale_to_compare_to][:avo]).freeze

  locales_with_missing_keys = {}

  I18n.available_locales.without(locale_to_compare_to).reject do |locale|
    # Skip locales that don't contain avo translations
    translations[locale][:avo].nil?
  end.each do |locale|
    locale_keys = collect_translation_keys([], translations[locale][:avo])

    missing_keys = reference_keys - locale_keys

    locales_with_missing_keys[locale] = missing_keys if missing_keys.any?
  end

  locales_with_missing_keys.each do |locale, missing_keys|
    puts "Missing keys in #{locale}:"
    puts missing_keys.map { |k| "  #{locale}.avo.#{k}" }.join("\n")
  end

  # Signal an error if any missing keys were found (for CI)
  exit 1 if locales_with_missing_keys.any?
end
