module Avo
  module Concerns
    module HasActionStimulusControllers
      extend ActiveSupport::Concern

      included do
        class_attribute :stimulus_controllers, default: ""
      end

      def get_stimulus_controllers
        self.class.stimulus_controllers
      end
    end
  end
end
