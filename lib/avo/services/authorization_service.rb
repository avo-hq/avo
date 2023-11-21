module Avo
  module Services
    class AuthorizationService
      attr_accessor :user
      attr_accessor :record
      attr_accessor :policy_class

      class << self
        def authorize(*args, **kwargs)
          true
        end

        def apply_policy(user, query)
          query
        end
      end

      def initialize(user = nil, record = nil, policy_class: nil)
        @user = user
        @record = record
        @policy_class = NilPolicy
      end

      def set_record(record)
        @record = record

        self
      end

      def apply_policy(query)
        query
      end

      def authorize_action(*args)
        true
      end

      def has_method?(*args, **kwargs)
        false
      end

      class NilPolicy
      end
    end
  end
end
