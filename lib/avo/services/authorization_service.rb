module Avo
  module Services
    class AuthorizationService
      attr_accessor :user
      attr_accessor :record

      class << self
        def authorize(user, record, action, policy_class: nil, **args)
          return true if skip_authorization
          return true if user.nil?

          policy_class ||= Pundit.policy(user, record)&.class
          begin
            if policy_class&.new(user, record)
              Pundit.authorize user, record, action, policy_class: policy_class
            end

            true
          rescue Pundit::NotDefinedError => e
            return false unless Avo.configuration.raise_error_on_missing_policy

            raise e
          rescue => error
            if args[:raise_exception] == false
              false
            else
              raise error
            end
          end
        end

        def authorize_action(user, record, action, policy_class: nil, **args)
          action = Avo.configuration.authorization_methods.stringify_keys[action.to_s] || action

          # If no action passed we should raise error if the user wants that.
          # If not, just allow it.
          if action.nil?
            raise Pundit::NotDefinedError.new "Policy method is missing" if Avo.configuration.raise_error_on_missing_policy

            return true
          end

          # Add the question mark if it's missing
          action = "#{action}?" unless action.end_with? "?"
          authorize(user, record, action, policy_class: policy_class, **args)
        end

        def apply_policy(user, model, policy_class: nil)
          return model if skip_authorization || user.nil?

          begin
            if policy_class
              policy_class::Scope.new(user, model).resolve
            else
              Pundit.policy_scope! user, model
            end
          rescue Pundit::NotDefinedError => e
            return model unless Avo.configuration.raise_error_on_missing_policy

            raise e
          end
        end

        def skip_authorization
          Avo::App.license.lacks_with_trial :authorization
        end

        def authorized_methods(user, record)
          [:new, :edit, :update, :show, :destroy].map do |method|
            [method, authorize(user, record, Avo.configuration.authorization_methods[method])]
          end.to_h
        end

        def defined_methods(user, record, policy_class: nil, **args)
          return Pundit.policy!(user, record).methods if policy_class.nil?

          # I'm aware this will not raise a Pundit error.
          # Should the policy not exist, it will however raise an uninitialized constant error, which is probably what we want when specifying a custom policy
          policy_class.new(user, record).methods
        rescue Pundit::NotDefinedError => e
          return [] unless Avo.configuration.raise_error_on_missing_policy

          raise e
        rescue => error
          if args[:raise_exception] == false
            []
          else
            raise error
          end
        end
      end

      def initialize(user = nil, record = nil, policy_class: nil)
        @user = user
        @record = record
        @policy_class = policy_class || Pundit.policy(user, record)&.class
      end

      def authorize(action, **args)
        self.class.authorize(user, record, action, policy_class: @policy_class, **args)
      end

      def set_record(record)
        @record = record

        self
      end

      def set_user(user)
        @user = user

        self
      end

      def authorize_action(action, **args)
        self.class.authorize_action(user, record, action, policy_class: @policy_class, **args)
      end

      def apply_policy(model)
        self.class.apply_policy(user, model, policy_class: @policy_class)
      end

      def defined_methods(model, **args)
        self.class.defined_methods(user, model, policy_class: @policy_class, **args)
      end

      def has_method?(method, **args)
        defined_methods(record, **args).include? method.to_sym
      end
    end
  end
end
