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
        when :edit
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
          "resource-#{view}-view-value": view
        }

        get_stimulus_controllers.split(" ").each do |controller|
          # add the parentController for each extra controller so we can target the main controller (resource-edit/resource-show/resource-index)
          # in custom controllers.
          attributes["#{controller}-target"] = "parentController"
          attributes["#{controller}-view-value"] = view
        end

        attributes
      end
    end
  end
end
