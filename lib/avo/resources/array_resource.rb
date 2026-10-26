module Avo
  module Resources
    class ArrayResource < Base
      abstract_resource!

      extend ActiveSupport::DescendantsTracker

      include Avo::Concerns::FindAssociationField

      delegate :model_class, to: :class

      class_attribute :pagination, default: {
        type: :array
      }

      # Shows the create, edit and delete controls. The records have no save! or destroy!,
      # so the resource defines its own save_record and destroy_record.
      class_attribute :writable, default: false

      # A page a paginated source already cut, with the total it reported. Pagy reads the total from
      # `count` and takes the records through `offset` and `limit` as they are, instead of slicing them.
      unless defined?(Page)
        Page = Data.define(:records, :count) do
          include Enumerable

          def each(&) = records.each(&)

          def offset(_) = self

          def limit(_) = records
        end
      end

      attr_writer :index_params

      class << self
        def query_scope(index_params: nil, **) = new.tap { _1.index_params = index_params }.fetch_records

        # Each array resource keeps its own model class. It starts as a placeholder class and
        # fetch_records replaces it with the class of the records it builds or finds.
        def model_class
          return @model_class if @model_class

          resource_class = self

          Avo.send(:remove_const, class_name) if Avo.const_defined?(class_name, false)

          @model_class = Avo.const_set(
            class_name,
            Class.new do
              include ActiveModel::Model

              define_singleton_method(:primary_key) { nil }
              define_singleton_method(:class_name) { resource_class.class_name }
              define_singleton_method(:all) { resource_class.new.fetch_records }
            end
          )
        end
      end

      def records = []

      # The index page shown and its size, so `records` can fetch only that page. nil outside an index.
      def page = @index_params&.dig(:page)

      def per_page = @index_params&.dig(:per_page)

      # What an Array field shows for `record`: its block's result, which can read the page shown,
      # or else the record's method of the same name.
      def records_from_field(field, record)
        Avo::ExecutionContext.new(target: field.block, record:, page:, per_page:).handle || record.try(field.id)
      end

      # Fetching builds the model class with an accessor per attribute, so a new record can be filled.
      def new_record
        fetch_records
        super
      end

      def find_record(id, query: nil, params: nil)
        return find_with_custom_finder([id], params:).first if self.class.custom_find_record_method?

        fetched_records = fetch_records

        return super(id, query: fetched_records, params:) if is_active_record_relation?(fetched_records)

        fetched_records.find { |record| record.id.to_s == id.to_s }
      end

      def find_records(ids, query: nil, params: nil)
        return find_with_custom_finder(ids, params:) if self.class.custom_find_record_method?

        fetched_records = fetch_records

        return super(ids, query: fetched_records, params:) if is_active_record_relation?(fetched_records)

        ids.map { |id| fetched_records.find { |record| record.id.to_s == id.to_s } }
      end

      def fetch_records(array_of_records = nil)
        array_of_records ||= records
        raise "Unable to fetch any #{class_name}" if array_of_records.nil?

        # When the array of records is declared in a field's block, we need to get that block from the parent resource
        # If there is no block try to pick those from the parent_record
        # Fallback to resource's def records method
        if params[:via_resource_class].present?
          via_resource = Avo.resource_manager.get_resource(params[:via_resource_class])
          via_record = via_resource.find_record params[:via_record_id], params: params
          via_resource = via_resource.new record: via_record, view: :show
          via_resource.detect_fields

          association_field = find_association_field(resource: via_resource, association: route_key)

          array_of_records = records_from_field(association_field, via_record) || array_of_records
        end

        # A paginated source returns its page with the total, as `{records:, count:}`
        @fetched_records ||= if array_of_records.is_a?(Hash)
          Page.new(records: cast_records(array_of_records[:records]), count: array_of_records[:count])
        else
          cast_records(array_of_records)
        end
      end

      def is_array_of_active_records?(array_of_records = records)
        @is_array_of_active_records ||= array_of_records.all? { |element| element.is_a?(ActiveRecord::Base) }
      end

      def is_active_record_relation?(array_of_records = records)
        @is_active_record_relation ||= array_of_records.is_a?(ActiveRecord::Relation)
      end

      def is_array_of_store_model?(array_of_records = records)
        @is_array_of_store_model ||= defined?(StoreModel::Model) && array_of_records.all? { |element| element.is_a?(StoreModel::Model) }
      end

      def resource_type_array? = true

      def read_only_array? = !writable

      # Base derives it from ActiveRecord's base_class.
      def form_scope = class_name.underscore

      def sort_by_param = nil

      def sorting_supported? = false

      private

      # A paginated source holds one page, so a custom finder fetches each record by itself.
      # `query` is fetched only if the finder reads it, as one on an Active Record backed resource does.
      def find_with_custom_finder(ids, params:)
        resource = self
        found = ids.map do |id|
          context = Avo::ExecutionContext.new(target: find_record_method, id:, params:, model_class:)
          context.define_singleton_method(:query) { resource.fetch_records }
          context.handle
        end

        # The hashes share one model class, as the records from `records` do
        cast = cast_records(found.grep(Hash))
        found.map { |record| record.is_a?(Hash) ? cast.shift : record }
      end

      def cast_records(array_of_records)
        if array_of_records.empty?
          array_of_records
        elsif is_array_of_active_records?(array_of_records)
          self.class.model_class = array_of_records.first.class
          model_class.where(id: array_of_records.map(&:id))
        elsif is_active_record_relation?(array_of_records)
          self.class.model_class = array_of_records.try(:model)
          array_of_records
        elsif is_array_of_store_model?(array_of_records)
          self.class.model_class = array_of_records.first.class
          array_of_records
        else
          # Dynamically create a class with accessors for all unique keys from the records
          keys = array_of_records.flat_map(&:keys).uniq
          resource_class = self.class

          Avo.send(:remove_const, class_name) if Avo.const_defined?(class_name, false)

          custom_class = Avo.const_set(
            class_name,
            Class.new do
              include ActiveModel::Model

              # Dynamically define accessors
              attr_accessor(*keys)

              define_method(:to_param) do
                id
              end

              define_singleton_method(:primary_key) { nil }
              define_singleton_method(:class_name) { resource_class.class_name }
              define_singleton_method(:all) { resource_class.new.fetch_records }
            end
          )

          # Keep model_class in sync so the records are instances of it
          resource_class.model_class = custom_class

          # Map the records to instances of the dynamically created class
          array_of_records.map do |item|
            custom_class.new(item)
          end
        end
      end
    end
  end
end
