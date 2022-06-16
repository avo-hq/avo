module Avo
  module Services
    class DecoratorService
      class << self
        def decorate_record(record:, decoration:, **args)
          return record if decoration.blank?

          Avo::Hosts::ViewRecordHost.new(block: decoration, record: record, **args).handle
        end

        def decorate_collection(collection:, decoration:, **args)
          return collection if decoration.blank?

          Avo::Hosts::ViewCollectionHost.new(block: decoration, collection: collection, **args).handle
        end
      end
    end
  end
end
