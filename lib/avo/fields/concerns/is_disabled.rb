module Avo
  module Fields
    module Concerns
      module IsDisabled
        extend ActiveSupport::Concern

        attr_reader :disabled

        def is_disabled?
          if disabled.respond_to? :call
            Avo::Hosts::ResourceViewRecordHost.new(block: disabled, record: model, view: view, resource: resource).handle
          else
            disabled
          end
        end
      end
    end
  end
end
