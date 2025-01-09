module Avo
  module Resources
    class ArrayResource < Base
      extend ActiveSupport::DescendantsTracker

      delegate :model_class, to: :class

      class_attribute :pagination, default: {
        type: :array
      }

      class << self
        def model_class
          ActiveSupport::OrderedOptions.new.tap do |obj|
            obj.model_name = ActiveSupport::OrderedOptions.new.tap do |thing|
              thing.plural = "Array"
            end
          end
        end
      end

      def find_record(id, query: nil, params: nil)
        records.find { |i| i.id.to_s == id.to_s }
      end

      def fetch_records
        # Dynamically create a class with accessors for all unique keys from the records
        keys = records.flat_map(&:keys).uniq

        custom_class = Class.new do
          include ActiveModel::Model

          # Dynamically define accessors
          attr_accessor(*keys)

          define_method(:to_param) do
            id
          end
        end

        # Map the records to instances of the dynamically created class
        records.map do |item|
          custom_class.new(item)
        end
      end
    end
  end
end
