# frozen_string_literal: true

module Avo
  module Fields
    module Concerns
      module IsLoading
        extend ActiveSupport::Concern

        attr_reader :loading

        def loading?
          !!Avo::ExecutionContext.new(target: loading, record: record, view: view, resource: resource).handle
        end
      end
    end
  end
end
