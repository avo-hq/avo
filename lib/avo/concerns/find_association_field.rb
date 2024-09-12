module Avo
  module Concerns
    module FindAssociationField
      # The supported association types are defined in the ASSOCIATIONS constant.
      unless defined?(ASSOCIATIONS)
        ASSOCIATIONS = ["belongs_to", "has_one", "has_many", "has_and_belongs_to_many"]
      end

      # This method is used to find an association field for a given resource.
      # Ideally, the exact type of the association should be known in advance.
      # However, there are cases where the type is unknown
      # and the method will return the first matching association field
      # based on the provided association name.
      def find_association_field(resource:, association:)
        resource.get_field_definitions.find do |field|
          (field.id == association.to_sym) && field.type.in?(ASSOCIATIONS)
        end
      end
    end
  end
end
