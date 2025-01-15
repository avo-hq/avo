module Avo
  module Resources
    class ArrayResource < Base
      extend ActiveSupport::DescendantsTracker

      include Avo::Concerns::FindAssociationField

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

      def records = []

      def find_record(id, query: nil, params: nil)
        fetched_records = fetch_records

        return super(id, query: fetched_records, params:) if is_active_record_relation?(fetched_records)

        fetched_records.find { |i| i.id.to_s == id.to_s }
      end

      def fetch_records(array_of_records = records)
        raise "Unable to fetch any #{name}" if array_of_records.nil?

        # When the array of records is declared in a field's block, we need to get that block from the parent resource
        # If there is no block try to pick those from the parent_record
        # Fallback to resource's def records method
        if params[:via_resource_class].present?
          via_resource = Avo.resource_manager.get_resource(params[:via_resource_class])
          via_record = via_resource.find_record params[:via_record_id], params: params
          via_resource = via_resource.new record: via_record, view: :show
          via_resource.detect_fields

          association_field = find_association_field(resource: via_resource, association: route_key)

          records_from_field_or_record = Avo::ExecutionContext.new(target: association_field.block).handle || via_record.try(route_key)

          array_of_records = records_from_field_or_record || array_of_records
        end

        @fetched_records ||= if is_array_of_active_records?(array_of_records)
          @@model_class = array_of_records.first.class
          @@model_class.where(id: array_of_records.map(&:id))
        elsif is_active_record_relation?(array_of_records)
          @@model_class = array_of_records.try(:model)
          array_of_records
        else
          # Dynamically create a class with accessors for all unique keys from the records
          keys = array_of_records.flat_map(&:keys).uniq

          custom_class = Class.new do
            include ActiveModel::Model

            # Dynamically define accessors
            attr_accessor(*keys)

            define_method(:to_param) do
              id
            end
          end

          # Map the records to instances of the dynamically created class
          array_of_records.map do |item|
            custom_class.new(item)
          end
        end
      end

      def is_array_of_active_records?(array_of_records = records)
        @is_array_of_active_records ||= array_of_records.all? { |element| element.is_a?(ActiveRecord::Base) }
      end

      def is_active_record_relation?(array_of_records = records)
        @is_active_record_relation ||= array_of_records.is_a?(ActiveRecord::Relation)
      end

      def resource_type_array? = true

      def sort_by_param = nil
    end
  end
end
