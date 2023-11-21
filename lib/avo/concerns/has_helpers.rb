module Avo
  module Concerns
    module HasHelpers
      def helpers
        @helpers ||= Class.new do
          def initialize
            helper_names = ActionController::Base.all_helpers_from_path Rails.root.join("app", "helpers")
            helpers = ActionController::Base.modules_for_helpers helper_names

            helpers.each do |helper|
              extend helper
            end
          end
        end.new
      end
    end
  end
end
