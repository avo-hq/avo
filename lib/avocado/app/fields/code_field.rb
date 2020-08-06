module Avocado
  module Fields
    class CodeField < Field
      def initialize(name, **args, &block)
        @defaults = {
          component: 'code-field',
        }

        hide_on :index

        super(name, **args, &block)

        @language = args[:language].present? ? args[:language].to_s : 'javascript'
        @theme = args[:theme].present? ? args[:theme].to_s : 'material-darker'
      end

      def hydrate_field(fields, model, resource, view)
        {
          language: @language,
          theme: @theme,
        }
      end
    end
  end
end
