module Avo
  module Resources
    module Controls
      class Action < BaseControl
        attr_reader :klass
        attr_reader :icon
        attr_reader :color
        attr_reader :style

        def initialize(klass, model: nil, resource: nil, view: nil, **args)
          @klass = klass
          @args = args
          @icon = args[:icon] || "play"
          @color = args[:color] || :gray
          @style = args[:style] || :text
          @resource = resource
          @model = model
          @view = view
        end

        def action
          return @instance if @instance.present?

          @instance = @klass.new(model: @model, resource: @resource, view: @view)
        end

        def path
          Avo::Services::URIService.parse(@resource.record_path).append_paths("actions", action.param_id).to_s
        end

        def label
          @args[:label] || action.action_name
        end
      end
    end
  end
end
