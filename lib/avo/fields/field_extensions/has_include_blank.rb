module Avo
  module Fields
    module FieldExtensions
      module HasIncludeBlank
        def include_blank
          if @args[:include_blank] == true
            placeholder || "—"
          elsif @args[:include_blank] == false
            false
          elsif @args.key?(:include_blank)
            execute_context(@args[:include_blank])
          else
            translated_field_option(:include_blank)
          end
        end
      end
    end
  end
end
