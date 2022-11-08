module Avo
  module Fields
    module Concerns
      module HasDefault
        extend ActiveSupport::Concern

        def computed_default_value
          if default.respond_to? :call
            Avo::Hosts::ResourceViewRecordHost.new(block: default, record: model, view: view, resource: resource).handle
          else
            default
          end
        end
      end
    end
  end
end
