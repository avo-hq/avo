module Avo
  module Concerns
    module AssociationQueryScope
      def association_query_scope(parent_resource:, parent_record:, association_name:, authorization:, resource:, field_association_name: association_name)
        valid_association_name = BaseResource.valid_association_name(parent_record, association_name)
        association_field = find_association_field(resource: parent_resource, association: field_association_name)

        query = authorization.apply_policy(
          parent_record.send(valid_association_name)
        )

        if association_field&.scope.present?
          query = Avo::ExecutionContext.new(
            target: association_field.scope,
            query: query,
            parent: parent_record,
            resource: resource,
            parent_resource: parent_resource
          ).handle
        end

        query
      end

      def association_summary?
        params[:via_record_id].present? &&
          params[:via_resource_class].present? &&
          (params[:association_name].present? || params[:related_name].present?)
      end

      def build_association_scope_from_params(resource:, authorization:)
        field = set_parent_from_via_params(association: params[:association_name] || params[:related_name], resource_class: resource.class)

        association_query_scope(
          parent_resource: @parent_resource,
          parent_record: @parent_record,
          association_name: field.association_name,
          field_association_name: field.id,
          authorization: authorization,
          resource: resource
        )
      end

      # Finds the parent record and resource the `via_resource_class` and `via_record_id` params name, and
      # returns the parent's field for the association once it's known to list `resource_class` and the user
      # may view it.
      def set_parent_from_via_params(association:, resource_class:)
        parent_resource_class = Avo.resource_manager.get_resource(params[:via_resource_class])
        raise ActiveRecord::RecordNotFound if parent_resource_class.nil?

        @parent_record = parent_resource_class.find_record(params[:via_record_id], params: params)
        @parent_resource = parent_resource_class.new(
          record: @parent_record,
          view: Avo::ViewInquirer.new("show")
        )
        @parent_resource.detect_fields
        field = find_association_field(resource: @parent_resource, association: association)
        # Only the panel fields (has_one, has_many, has_and_belongs_to_many, array) list records through the parent.
        raise ActiveRecord::RecordNotFound unless field.is_a?(Avo::Fields::FrameBaseField)

        authorize_via_association field, resource_class

        field
      end
    end
  end
end
