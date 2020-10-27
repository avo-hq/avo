module Avo
  class TranslationService
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
      begin
        YAML.load(localization_content)[locale]
      rescue => exception
      end
    end

    private
      def localization_content
        begin
          path = Rails.root.join('config', 'locales', "#{locale}.yml")

          if File.exist? path
            return File.read path
          end

          self.locale = 'en'
          File.read(Rails.root.join('config', 'locales', 'en.yml'))
        rescue => exception
        end
      end
  end
end
