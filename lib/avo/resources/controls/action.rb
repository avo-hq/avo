module Avo
  module Resources
    module Controls
      class Action < BaseControl
        attr_reader :klass
        attr_reader :model
        attr_reader :resource
        attr_reader :view
        attr_reader :index
        attr_reader :args

        def initialize(klass, model: nil, resource: nil, view: nil, index: nil, **args)
          super(**args)

          @klass = klass
          @resource = resource
          @model = model
          @view = view
          @index = index
        end

        def action
          @instance ||= klass.new(model: model, resource: resource, view: view, index: index)
        end

        def path
          Avo::Services::URIService
            .parse(@resource.record_path)
            .append_paths("actions", action.param_id, action.index).to_s
        end

        def label
          args[:label] || action.action_name
        end
      end
    end
  end
end
