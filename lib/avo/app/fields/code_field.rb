module Avo
  module Fields
    class CodeField < Field
      def initialize(name, **args, &block)
        @defaults = {
          partial_name: 'code-field',
        }

        hide_on :index

        super(name, **args, &block)

        @language = args[:language].present? ? args[:language].to_s : 'javascript'
        @theme = args[:theme].present? ? args[:theme].to_s : 'material-darker'
        @height = args[:height].present? ? args[:height].to_s : 'auto'
      end

      def hydrate_field(fields, model, resource, view)
        {
          language: @language,
          theme: @theme,
          height: @height,
        }
      end
    end
  end
end
