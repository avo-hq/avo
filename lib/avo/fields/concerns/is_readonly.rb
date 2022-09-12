module Avo
  module Fields
    module Concerns
      module IsReadonly
        extend ActiveSupport::Concern

        def is_readonly?
          if readonly.respond_to? :call
            Avo::Hosts::ViewRecordHost.new(block: readonly, record: model, view: view).handle
          else
            readonly
          end
        end
      end
    end
  end
end
