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
          @@model_class ||= ActiveSupport::OrderedOptions.new.tap do |obj|
            obj.model_name = ActiveSupport::OrderedOptions.new.tap do |thing|
              thing.plural = route_key
            end
          end
        end
      end

      def find_record(id, query: nil, params: nil)
        return super if array_of_active_records?

        fetch_records.find { |i| i.id.to_s == id.to_s }
      end

      def fetch_records
        @fetched_records ||= if array_of_active_records?
          @@model_class = records.model
          records
        else
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

      def array_of_active_records?
        @array_of_active_records ||= records.is_a?(ActiveRecord::Relation)
      end
    end
  end
end
