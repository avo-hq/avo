module Avo
  module Fields
    class BelongsToField < BaseField
      attr_reader :searchable
      attr_reader :polymorphic_as
      attr_reader :relation_method
      attr_reader :types

      def initialize(id, **args, &block)
        args[:placeholder] ||= I18n.t("avo.choose_an_option")

        super(id, **args, &block)

        @searchable = args[:searchable] == true
        @polymorphic_as = args[:polymorphic_as]
        @types = args[:types]
        @relation_method = name.to_s.parameterize.underscore
      end

      def value
        super(polymorphic_as)
      end

      def options
        ::Avo::Services::AuthorizationService.apply_policy(user, target_resource.class.query_scope).all.map do |model|
          {
            value: model.id,
            label: model.send(target_resource.class.title)
          }
        end
      end

      def values_for_type(type)
        ::Avo::Services::AuthorizationService.apply_policy(user, type).all.map do |model|
          [model.send(App.get_resource_by_model_name(type).class.title), model.id]
        end
      end

      def database_value
        target_resource.id
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
        if polymorphic_as.present?
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
