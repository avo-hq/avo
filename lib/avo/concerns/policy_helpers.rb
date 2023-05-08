module Avo
  module Concerns
    module PolicyHelpers
      extend ActiveSupport::Concern

      class_methods do
        def inherit_association_from_policy(association_name, policy_class)
          [:create, :edit, :update, :destroy, :show, :reorder, :act_on].each do |method_action|
            define_policy_method(method_action, association_name, policy_class)
          end

          define_policy_method("view", association_name, policy_class, "index")
        end

        private

        # Define a method for the given action and association name.
        # Call the policy class with the given action passing the user and record.
        # Example:
        #  def create_team_members?
        #   TeamMemberPolicy.new(user, record).create?
        #  end
        def define_policy_method(method_action, association_name, policy_class, policy_action = method_action)
          define_method "#{method_action}_#{association_name}?" do
            policy_class.new(user, record).send "#{policy_action}?"
          end
        end
      end
    end
  end
end
