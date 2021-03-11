module Avo
  module Services
    class AuthorizationService
      attr_accessor :user
      attr_accessor :record

      def initialize(user = nil, record = nil)
        @user = user
        @record = record
      end

      def authorize(action, **args)
        self.class.authorize(user, record, action, **args)
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
        self.class.authorize_action(user, record, action, **args)
      end

      def apply_policy(model)
        self.class.apply_policy(user, model)
      end

      class << self
        def authorize(user, record, action, **args)
          return true if skip_authorization
          return true if user.nil?

          # puts '----->'.inspect

          begin
            if Pundit.policy user, record
              Pundit.authorize user, record, action
            end

            # puts 'true authorize'.inspect
            true
          rescue Pundit::NotDefinedError => error
            # puts 'not_defined'.inspect
            false
          rescue => error
            # puts ['general raise', args].inspect
            if args[:raise_exception] == false
              # puts 1.inspect
              false
            else
              # puts 2.inspect
              raise error
            end
          end


          # abort action.inspect

          #   return true
          # end

          # false
          # begin
          # rescue Pundit::NotAuthorizedError => error
          #   false
          # end
        end

        def authorize_action(user, record, action, **args)
          action = Avo.configuration.authorization_methods.stringify_keys[action.to_s]

          return true if action.nil?

          authorize user, record, action, **args
        end

        def apply_policy(user, model)
          return model if skip_authorization
          return model if user.nil?

          begin
            Pundit.policy_scope! user, model
          rescue => exception
            model
          end
        end

        def skip_authorization
          Avo::App.license.lacks :authorization
        end

        def authorized_methods(user, record)
          [:new, :edit, :update, :show, :destroy].map do |method|
            [method, authorize(user, record, Avo.configuration.authorization_methods[method])]
          end.to_h
        end

        def get_policy(user, record)
          Pundit.policy user, record
        end
      end
    end
  end
end
