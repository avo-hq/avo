module Avo
  class TranslationService
    FALLBACK_LOCALE_FILE = Rails.root.join('config', 'locales', 'en.yml')

    attr_accessor :locale

    def initialize(locale = nil)
      @locale = locale

      if @locale.nil?
        @locale = Avo.configuration.language_code
      end

      if @locale.nil?
        @locale = 'en'
      end
    end

    def javascript_translations
      en_translation = load_translation_file FALLBACK_LOCALE_FILE

      begin
        translation = load_translation_file localization_content
      rescue => exception
        return en_translation
      end

      en_translation.merge translation
    end

    private
      def load_translation_file(path)
        begin
          translation = YAML.load(File.read(path))
        rescue => exception
        end
      end

      def localization_content
        begin
          path = Rails.root.join('config', 'locales', "#{locale}.yml")

          if File.exist? path
            return path
          end

          self.locale = 'en'
          FALLBACK_LOCALE_FILE
        rescue => exception
        end
      end
  end
end
