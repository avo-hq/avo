module Avo
  module Services
    class AuthorizationService
      attr_accessor :user
      attr_accessor :record
      attr_accessor :policy_class

      class << self
        def client
          client = Avo.configuration.authorization_client

          client = nil if Avo::App.license.lacks(:authorization)

          klass = case client
          when nil
            nil_client
          when :pundit
            pundit_client
          else
            if client.is_a?(String)
              client.safe_constantize
            else
              client
            end
          end

          klass.new
        end

        def authorize(user, record, action, policy_class: nil, **args)
          return true if skip_authorization

          client.authorize user, record, action, policy_class: policy_class

          true
        rescue NoPolicyError => error
          # By default, Avo allows anything if you don't have a policy present.
          return true unless Avo.configuration.raise_error_on_missing_policy

          raise error
        rescue => error
          if args[:raise_exception] == false
            false
          else
            raise error
          end
        end

        def authorize_action(user, record, action, policy_class: nil, **args)
          action = Avo.configuration.authorization_methods.stringify_keys[action.to_s] || action

          # If no action passed we should raise error if the user wants that.
          # If not, just allow it.
          if action.nil?
            raise NoPolicyError.new "Policy method is missing" if Avo.configuration.raise_error_on_missing_policy

            return true
          end

          # Add the question mark if it's missing
          action = "#{action}?" unless action.end_with? "?"
          authorize(user, record, action, policy_class: policy_class, **args)
        end

        def apply_policy(user, model, policy_class: nil)
          return model if skip_authorization

          client.apply_policy(user, model, policy_class: policy_class)
        rescue NoPolicyError => error
          return model unless Avo.configuration.raise_error_on_missing_policy

          raise error
        end

        def skip_authorization
          Avo::App.license.lacks_with_trial :authorization
        end

        def defined_methods(user, record, policy_class: nil, **args)
          return client.policy!(user, record).methods if policy_class.nil?

          # I'm aware this will not raise a Pundit error.
          # Should the policy not exist, it will however raise an uninitialized constant error, which is probably what we want when specifying a custom policy
          policy_class.new(user, record).methods
        rescue NoPolicyError => error
          return [] unless Avo.configuration.raise_error_on_missing_policy

          raise error
        rescue => error
          if args[:raise_exception] == false
            []
          else
            raise error
          end
        end

        def pundit_client
          raise Avo::MissingGemError.new("Please add `gem 'pundit'` to your Gemfile.") unless defined?(Pundit)

          Avo::Services::AuthorizationClients::PunditClient
        end

        def nil_client
          Avo::Services::AuthorizationClients::NilClient
        end
      end

      def initialize(user = nil, record = nil, policy_class: nil)
        @user = user
        @record = record
        @policy_class = policy_class || self.class.client.policy(user, record)&.class
      end

      def set_record(record)
        @record = record

        self
      end

      def authorize_action(action, **args)
        self.class.authorize_action(user, args[:record] || record, action, policy_class: policy_class, **args)
      end

      def apply_policy(model)
        self.class.apply_policy(user, model, policy_class: policy_class)
      end

      def defined_methods(model, **args)
        self.class.defined_methods(user, model, policy_class: policy_class, **args)
      end

      def has_method?(method, **args)
        method = "#{method}?" unless method.to_s.end_with? "?"
        defined_methods(args[:record] || record, **args).include? method.to_sym
      end

      # Check the received method to see if the user overrode it in their config and then checks if it's present on the policy.
      def has_action_method?(method, **args)
        method = Avo.configuration.authorization_methods.stringify_keys[method.to_s] || method

        has_method? method, **args
      end
    end
  end
end
