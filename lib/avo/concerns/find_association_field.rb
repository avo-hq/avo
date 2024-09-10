module Avo
  module Concerns
    module FindAssociationField
      def find_association_field(resource:, association:)
        if params[:turbo_frame] && params[:turbo_frame].starts_with?("has_")
          type = params[:turbo_frame][/.*(?=_field)/]

          resource.get_field_definitions.find do |field|
            (field.id == association) && (field.type == type)
          end
        else
          resource.get_field association
        end
      end
    end
  end
end
