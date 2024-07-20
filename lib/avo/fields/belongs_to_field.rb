module Avo
  module Fields
    # The field can be in multiple scenarios where it needs different types of data and displays the state differently.
    # For example the non-polymorphic, non-searchable variant is the easiest to support. You only need to populate a simple select with the ID of the associated record and the list of records.
    # For the searchable polymorphic variant you need to provide the type of the association (Post, Project, Team), the label of the associated record ("Cool post title") and the ID of that record.
    # Furthermore, the way Avo works, it needs to do some queries on the back-end to fetch the required information.
    #
    # Field scenarios:
    # 1. Create new record
    #   List of records
    # 2. Create new record as association
    #   List of records, the ID
    # 3. Create new searchable record
    #   Nothing really. The records will be fetched from the search API
    # 4. Create new searchable record as association
    #   The associated record label and ID. The records will be fetched from the search API
    # 5. Create new polymorphic record
    #   Type & ID
    # 6. Create new polymorphic record as association
    #   Type, list of records, and ID
    # 7. Create new polymorphic searchable record
    #   Type, Label and ID
    # 8. Create new polymorphic searchable record as association
    #   Type, Label and ID
    # 9. Edit a record
    #   List of records & ID
    # 10. Edit a record as searchable
    #   Label and ID
    # 11. Edit a record as an association
    #   List and ID
    # 12. Edit a record as an searchable association
    #   Label and ID
    # 13. Edit a polymorphic record
    #   Type, List of records & ID
    # 14. Edit a polymorphic record as searchable
    #   Type, Label and ID
    # 15. Edit a polymorphic record as an association
    #   Type, List and ID
    # 16. Edit a polymorphic record as an searchable association
    #   Type, Label and ID
    # Also all of the above with a namespaced model `Course/Link`

    # Variants
    # 1. Select belongs to
    # 2. Searchable belongs to
    # 3. Select Polymorphic belongs to
    # 4. Searchable Polymorphic belongs to

    # Requirements
    # - list
    # - ID
    # - label
    # - Type
    # - foreign_key
    # - foreign_key for poly type
    # - foreign_key for poly id
    # - is_disabled?

    class BelongsToField < BaseField
      include Avo::Fields::Concerns::IsSearchable
      include Avo::Fields::Concerns::UseResource

      attr_accessor :target

      attr_reader :polymorphic_as
      attr_reader :relation_method
      attr_reader :types # for Polymorphic associations
      attr_reader :allow_via_detaching
      attr_reader :attach_scope
      attr_reader :polymorphic_help
      attr_reader :link_to_record

      def initialize(id, **args, &block)
        args[:placeholder] ||= I18n.t("avo.choose_an_option")

        super(id, **args, &block)

        @searchable = args[:searchable] == true
        @polymorphic_as = args[:polymorphic_as]
        @types = args[:types]
        @relation_method = id.to_s.parameterize.underscore
        @allow_via_detaching = args[:allow_via_detaching] == true
        @attach_scope = args[:attach_scope]
        @polymorphic_help = args[:polymorphic_help]
        @target = args[:target]
        @use_resource = args[:use_resource] || nil
        @can_create = args[:can_create].nil? ? true : args[:can_create]
        @link_to_record = args[:link_to_record].present? ? args[:link_to_record] : false
      end

      def value
        if is_polymorphic?
          # Get the value from the pre-filled association record
          super(polymorphic_as)
        else
          # Get the value from the pre-filled association record
          super(relation_method)
        end
      end

      # The value
      def field_value
        value.send(database_value)
      rescue
        nil
      end

      # What the user sees in the text field
      def field_label
        label
      end

      def options
        values_for_type
      end

      def values_for_type(model = nil)
        resource = target_resource
        resource = Avo.resource_manager.get_resource_by_model_class model if model.present?

        query = resource.query_scope

        if attach_scope.present?
          query = Avo::ExecutionContext.new(target: attach_scope, query: query, parent: get_record).handle
        end

        query.all.map do |record|
          [resource.new(record: record).record_title, record.id]
        end
      end

      def database_value
        target_resource.id
      rescue
        nil
      end

      def type_input_foreign_key
        if is_polymorphic?
          "#{foreign_key}_type"
        end
      end

      def id_input_foreign_key
        if is_polymorphic?
          "#{foreign_key}_id"
        else
          foreign_key
        end
      end

      def is_polymorphic?
        polymorphic_as.present?
      rescue
        false
      end

      def foreign_key
        @foreign_key ||= if polymorphic_as.present?
          polymorphic_as
        elsif @record.present?
          get_model_class(@record).reflections[@relation_method].foreign_key
        elsif @resource.present? && @resource.model_class.reflections[@relation_method].present?
          @resource.model_class.reflections[@relation_method].foreign_key
        end
      end

      def reflection_for_key(key)
        get_model_class(get_record).reflections[key.to_s]
      rescue
        nil
      end

      # Get the model reflection instance
      def reflection
        reflection_for_key(id)
      rescue
        nil
      end

      def relation_model_class
        @resource.model_class
      end

      def label
        return if target_resource.blank?
        target_resource.new(record: value)&.record_title
      end

      def to_permitted_param
        if polymorphic_as.present?
          return [:"#{polymorphic_as}_type", :"#{polymorphic_as}_id"]
        end

        foreign_key.to_sym
      end

      def fill_field(record, key, value, params)
        return record unless record.methods.include? key.to_sym

        if polymorphic_as.present?
          valid_model_class = valid_polymorphic_class params[:"#{polymorphic_as}_type"]

          record.send(:"#{polymorphic_as}_type=", valid_model_class)

          # If the type is blank, reset the id too.
          if valid_model_class.blank?
            record.send(:"#{polymorphic_as}_id=", nil)
          else
            record.send(:"#{polymorphic_as}_id=", params["#{polymorphic_as}_id"])
          end
        else
          record.send("#{key}=", value)
        end

        record
      end

      def valid_polymorphic_class(possible_class)
        types.find do |type|
          type.to_s == possible_class.to_s
        end
      end

      def database_id
        # If the field is a polymorphic value, return the polymorphic_type as key and pre-fill the _id in fill_field.
        return :"#{polymorphic_as}_type" if polymorphic_as.present?

        foreign_key
      rescue
        id
      end

      def target_resource
        @target_resource ||= if use_resource.present?
          use_resource
        elsif is_polymorphic?
          if value.present?
            get_resource_by_model_class(value.class)
          else
            return nil
          end
        else
          reflection_key = polymorphic_as || id

          reflection_object = @record._reflections.with_indifferent_access[reflection_key]

          if reflection_object.klass.present?
            get_resource_by_model_class(reflection_object.klass.to_s)
          elsif reflection_object.options[:class_name].present?
            get_resource_by_model_class(reflection_object.options[:class_name])
          else
            App.get_resource_by_name reflection_key
          end
        end
      end

      def get_record
        @record || @resource.record
      end

      def default_name
        return polymorphic_as.to_s.humanize if polymorphic_as.present?

        super
      end

      def index_link_to_resource
        if @link_to_record.present?
          @resource
        else
          target_resource
        end
      end

      def index_link_to_record
        if @link_to_record.present?
          get_record
        else
          value
        end
      end

      # field :user, as: :belongs_to, can_create: true
      # Only can create when:
      #   - `can_create: true` option is present
      #   - target resource's policy allow creation (UserPolicy in this example)
      def can_create?(final_target_resource = target_resource)
        @can_create && final_target_resource.authorization.authorize_action(:create, raise_exception: false)
      end

      def form_field_label
        "#{id}_id"
      end

      def polymorphic_form_field_label
        "#{id}_type"
      end

      private

      def get_model_class(record)
        if record.nil?
          @resource.model_class
        elsif record.instance_of?(Class)
          record
        else
          record.class
        end
      end
    end
  end
end
