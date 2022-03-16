require "dry-initializer"

module Avo
  module Hosts
    class DashboardCard
      extend Dry::Initializer

      option :context
      option :range
      option :dashboard
      option :card
      option :params

      delegate :result, to: :card

      def compute_result
        instance_exec(&card.query_block)
      end
    end
  end
end
