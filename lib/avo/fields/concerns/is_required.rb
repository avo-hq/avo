module Avo
  module Fields
    module Concerns
      module IsRequired
        extend ActiveSupport::Concern

        def is_required?
          if required.respond_to? :call
            Avo::Hosts::ViewRecordHost.new(block: required, record: model, view: view).handle
          else
            required
          end
        end
      end
    end
  end
end
