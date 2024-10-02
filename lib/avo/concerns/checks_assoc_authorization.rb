module Avo
  module Concerns
    module ChecksAssocAuthorization
      extend ActiveSupport::Concern

      # Ex: A Post has many Comments
      def authorize_association_for(policy_method)
        return true if association_name.blank?

        # Hydrate the resource with the record if we have one
        reflection_resource.hydrate(record: @parent_record) if @parent_record.present?

        # Some policy methods should get the parent record in order to have the necessary information to do the authorization
        # Example: Post->has_many->Comments
        #
        # When you want to authorize the creation/attaching of a Comment, you don't have the Comment instance.
        # But you do have the Post instance and you can get that in your policy to authorize against.
        record = if policy_method.in? [:view, :create, :attach, :act_on]
          # Use the parent record (Post)
          reflection_resource.record
        else
          # Override the record with the child record (Comment)
          resource.record
        end

        # Use the policy methods from the parent (Post)
        service = reflection_resource.authorization

        if service.has_method?(method_name, raise_exception: false)
          service.authorize_action(
            :"#{policy_method}_#{association_name}?".to_sym,
            record:,
            raise_exception: false
          )
        else
          !Avo.configuration.whitelisting_authorization
        end
      end

      # Use the related_name as the base of the association
      def association_name
        @association_name ||= @reflection&.name
      end

      # Fetch the appropriate resource
      def reflection_resource
        @reflection_resource ||= field.resource
      end
    end
  end
end
