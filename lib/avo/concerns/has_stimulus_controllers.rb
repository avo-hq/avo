module Avo
  module Concerns
    module HasStimulusControllers
      extend ActiveSupport::Concern

      included do
        class_attribute :stimulus_controllers, default: ""
      end

      def get_stimulus_controllers
        return "" if view.nil?

        controllers = []

        case view.to_sym
        when :show
          controllers << "resource-show"
        when :new, :edit
          controllers << "resource-edit"
        when :index
          controllers << "resource-index"
        end

        controllers << self.class.stimulus_controllers

        controllers.join " "
      end

      def stimulus_data_attributes
        attributes = {
          controller: get_stimulus_controllers,
        }

        get_stimulus_controllers.split(" ").each do |controller|
          attributes["#{controller}-view-value"] = view
        end

        attributes
      end
    end
  end
end
