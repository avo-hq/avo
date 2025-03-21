module Avo
  module Concerns
    module HasResourceStimulusControllers
      extend ActiveSupport::Concern

      included do
        class_attribute :stimulus_controllers, default: ""
      end

      def get_stimulus_controllers
        return "" if @view.nil?

        controllers = []

        case @view.to_sym
        when :show
          controllers << "resource-show"
        when :new, :edit
          controllers << "resource-edit"
        when :index
          controllers << "resource-index record-selector"
        end

        controllers << self.class.stimulus_controllers

        controllers.reject(&:blank?).join " "
      end

      def stimulus_data_attributes
        attributes = {
          controller: get_stimulus_controllers,
        }

        get_stimulus_controllers.split(" ").each do |controller|
          attributes["#{controller}-view-value"] = @view
        end

        attributes
      end

      def add_stimulus_attributes_for(entity, attributes, target_name = nil)
        entity.get_stimulus_controllers.split(" ").each do |controller|
          attributes["#{controller}-target"] = target_name || "#{@field.id.to_s.underscore}_#{@field.type.to_s.underscore}_wrapper".camelize(:lower)
        end
      end
    end
  end
end
