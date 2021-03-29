module Avo
  module Fields
    module FieldExtensions
      module HasFieldName
        # Set the field name
        def field_name(name)
          self.field_name_attribute = name
        end

        # Get the field name
        def get_field_name
          return field_name_attribute if field_name_attribute.present?

          to_s.demodulize.underscore.gsub "_field", ""
        end
      end
    end
  end
end
