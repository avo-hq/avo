module Avo
  module Concerns
    module FindAssociationField
      def find_association_field(resource:, association: nil, type: nil)
        if params[:turbo_frame]&.starts_with?("has_") || type.present?
          type ||= params[:turbo_frame][/.*(?=_field)/]

          resource.get_field_definitions.find do |field|
            (field.id == association.to_sym) && (field.type == type.to_s)
          end
        else
          resource.get_field association
        end
      end
    end
  end
end
