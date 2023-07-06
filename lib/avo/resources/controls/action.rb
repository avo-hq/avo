module Avo
  module Resources
    module Controls
      class Action < BaseControl
        attr_reader :klass

        def initialize(klass, record: nil, resource: nil, view: nil, **args)
          super(**args)

          @klass = klass
          @resource = resource
          @record = record
          @view = view
        end

        def action
          @instance ||= @klass.new(
            model: @record,
            resource: @resource,
            view: @view,
            arguments: @resource.get_action_arguments(klass)
          )
        end

        def path
          Avo::Services::URIService.parse(@resource.record_path)
            .append_paths("actions")
            .append_query(action_id: action.param_id)
            .to_s
        end

        def label
          @args[:label] || action.action_name
        end
      end
    end
  end
end
