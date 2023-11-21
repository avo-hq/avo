module Avo
  module Fields
    module Concerns
      module HasFieldName
        extend ActiveSupport::Concern

        class_methods do
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
end
