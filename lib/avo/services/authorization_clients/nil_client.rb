module Avo
  module Services
    module AuthorizationClients
      class NilClient
        def authorize(user, record, action, policy_class: nil)
          true
        end

        def policy(user, record)
          NilPolicy.new
        end

        def policy!(user, record)
          NilPolicy.new
        end

        def apply_policy(user, model, policy_class: nil)
          model
        end

        class NilPolicy
          def initialize(user = nil, record = nil)
          end
          # rubocop:enable Style/RedundantInitialize

          def method_missing(method, *args, &block)
            self
          end

          def respond_to_missing?
            true
          end
        end
      end
    end
  end
end
