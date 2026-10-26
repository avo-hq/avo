# frozen_string_literal: true

module Avo
  # Helpers for the profile-menu language picker.
  module Locales
    # Holds the viewer's pick. Read by BaseApplicationController#set_avo_locale.
    COOKIE_NAME = "#{Avo::COOKIES_KEY}.locale"

    # Each language labeled in its own script, so a user can find their language
    # whatever the page is currently showing. These are constant per locale and
    # deliberately not translated.
    NAMES = {
      "ar" => "العربية",
      "bg" => "Български",
      "ca" => "Català",
      "cs" => "Čeština",
      "da" => "Dansk",
      "de" => "Deutsch",
      "el" => "Ελληνικά",
      "en" => "English",
      "es" => "Español",
      "fa" => "فارسی",
      "fi" => "Suomi",
      "fr" => "Français",
      "he" => "עברית",
      "hi" => "हिन्दी",
      "hr" => "Hrvatski",
      "hu" => "Magyar",
      "id" => "Bahasa Indonesia",
      "it" => "Italiano",
      "ja" => "日本語",
      "ko" => "한국어",
      "nb" => "Norsk bokmål",
      "nl" => "Nederlands",
      "nn" => "Norsk nynorsk",
      "pl" => "Polski",
      "pt" => "Português",
      "pt-BR" => "Português (Brasil)",
      "ro" => "Română",
      "ru" => "Русский",
      "sk" => "Slovenčina",
      "sv" => "Svenska",
      "th" => "ไทย",
      "tr" => "Türkçe",
      "ua" => "Українська",
      "uk" => "Українська",
      "vi" => "Tiếng Việt",
      "zh" => "中文",
      "zh-CN" => "中文（简体）",
      "zh-TW" => "中文（台灣）"
    }.freeze

    def self.name_for(locale)
      NAMES.fetch(locale.to_s) { locale.to_s.upcase }
    end

    # Whether the backend holds an `avo` tree for exactly this locale. Fallbacks
    # are disabled so a locale that would only borrow English does not count.
    def self.translated?(locale)
      I18n.exists?("avo", locale.to_s, fallback: false)
    end
  end
end
