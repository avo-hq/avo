require "dry-initializer"

module Avo
  module Hosts
    class CardVisibility
      extend Dry::Initializer

      option :block, default: proc { proc {} }
      option :current_user, default: proc { ::Avo::App.current_user }
      option :context, default: proc { ::Avo::App.context }
      option :parent
      option :card
      option :params, default: proc { ::Avo::App.params }

      def handle
        instance_exec(&block)
      end
    end
  end
end
