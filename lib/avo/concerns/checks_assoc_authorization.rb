module Avo
  module Concerns
    module ChecksAssocAuthorization
      extend ActiveSupport::Concern

      # Ex: A Post has many Comments
      def authorize_association_for(policy_method)
        return true if @reflection.blank?

        # Fetch the appropriate resource
        reflection_resource = field.resource

        # Fetch the record
        # Hydrate the resource with the record if we have one
        reflection_resource.hydrate(record: @parent_record) if @parent_record.present?

        # Use the related_name as the base of the association
        association_name = @reflection.name

        return true if association_name.blank?

        method_name = :"#{policy_method}_#{association_name}?".to_sym

        # Some policy methods should get the parent record in order to have the necessary information to do the authorization
        # Example: Post->has_many->Comments
        #
        # When you want to authorize the creation/attaching of a Comment, you don't have the Comment instance.
        # But you do have the Post instance and you can get that in your policy to authorize against.
        parent_policy_methods = [:view, :create, :attach, :act_on]

        record = if parent_policy_methods.include?(policy_method)
          # Use the parent record (Post)
          reflection_resource.record
        else
          # Override the record with the child record (Comment)
          resource.record
        end

        # Use the policy methods from the parent (Post)
        reflection_resource.authorization.authorize_action(method_name, record: record, raise_exception: false)
      end
    end
  end
end
