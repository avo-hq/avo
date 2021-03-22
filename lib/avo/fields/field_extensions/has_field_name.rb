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
          return self.field_name_attribute if self.field_name_attribute.present?

          self.to_s.demodulize.underscore.gsub '_field', ''
        end
      end
    end
  end
end
