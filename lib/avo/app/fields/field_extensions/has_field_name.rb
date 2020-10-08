module Avo
  module Fields
    module FieldExtensions
      module HasFieldName
        @@field_name_attribute = ''

        # Set the field name
        def field_name(name)
          @field_name_attribute = name
        end

        # Get the field name
        def field_name_attribute
          @field_name_attribute
        end

        # Get the field name from outside
        def get_field_name
          return field_name_attribute if field_name_attribute.present?

          self.to_s.demodulize.underscore.gsub '_field', ''
        end
      end
    end
  end
end
