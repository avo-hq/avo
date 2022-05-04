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
      attr_reader :polymorphic_as
      attr_reader :relation_method
      attr_reader :types # for Polymorphic associations
      attr_reader :allow_via_detaching
      attr_reader :attach_scope
      attr_reader :polymorphic_help

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
      end

      def searchable
        @searchable && ::Avo::App.license.has_with_trial(:searchable_associations)
      end

      def value
        if is_polymorphic?
          # Get the value from the pre-filled assoociation record
          super(polymorphic_as)
        else
          # Get the value from the pre-filled assoociation record
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
        value.send(target_resource.class.title)
      rescue
        nil
      end

      def options
        values_for_type
      end

      def values_for_type(model = nil)
        resource = target_resource
        resource = App.get_resource_by_model_name model if model.present?

        query = Avo::Services::AuthorizationService.apply_policy(user, resource.class.query_scope)

        if attach_scope.present?
          query = Avo::Hosts::AssociationScopeHost.new(block: attach_scope, query: query, parent: get_model).handle
        end

        query.all.map do |model|
          [model.send(resource.class.title), model.id]
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
        return polymorphic_as if polymorphic_as.present?

        if @model.present?
          get_model_class(@model).reflections[@relation_method].foreign_key
        elsif @resource.present? && @resource.model_class.reflections[@relation_method].present?
          @resource.model_class.reflections[@relation_method].foreign_key
        end
      end

      def reflection_for_key(key)
        get_model_class(get_model).reflections[key.to_s]
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
        value.send(target_resource.class.title)
      end

      def to_permitted_param
        if polymorphic_as.present?
          return ["#{polymorphic_as}_type".to_sym, "#{polymorphic_as}_id".to_sym]
        end

        foreign_key.to_sym
      end

      def fill_field(model, key, value, params)
        return model unless model.methods.include? key.to_sym

        if polymorphic_as.present?
          model.send("#{polymorphic_as}_type=", params["#{polymorphic_as}_type"])

          # If the type is blank, reset the id too.
          if params["#{polymorphic_as}_type"].blank?
            model.send("#{polymorphic_as}_id=", nil)
          else
            model.send("#{polymorphic_as}_id=", params["#{polymorphic_as}_id"])
          end
        else
          model.send("#{key}=", value)
        end

        model
      end

      def database_id(model)
        # If the field is a polymorphic value, return the polymorphic_type as key and pre-fill the _id in fill_field.
        return "#{polymorphic_as}_type" if polymorphic_as.present?

        foreign_key
      rescue
        id
      end

      def target_resource
        if is_polymorphic?
          if value.present?
            return App.get_resource_by_model_name(value.class)
          else
            return nil
          end
        end

        reflection_key = polymorphic_as || id

        if @model._reflections[reflection_key.to_s].klass.present?
          App.get_resource_by_model_name @model._reflections[reflection_key.to_s].klass.to_s
        elsif @model._reflections[reflection_key.to_s].options[:class_name].present?
          App.get_resource_by_model_name @model._reflections[reflection_key.to_s].options[:class_name]
        else
          App.get_resource_by_name reflection_key.to_s
        end
      end

      def get_model
        return @model if @model.present?

        @resource.model
      rescue
        nil
      end

      def name
        return polymorphic_as.to_s.humanize if polymorphic_as.present? && view == :index

        super
      end

      private

      def get_model_class(model)
        if model.instance_of?(Class)
          model
        else
          model.class
        end
      end
    end
  end
end
