module Avo
  module Fields
    class BelongsToField < BaseField
      attr_reader :searchable
      attr_reader :polymorphic_as
      attr_reader :polymorphic_for
      attr_reader :relation_method

      def initialize(id, **args, &block)
        args[:placeholder] ||= I18n.t("avo.choose_an_option")

        super(id, **args, &block)

        @searchable = args[:searchable] == true
        @polymorphic_as = args[:polymorphic_as]
        @polymorphic_for = args[:polymorphic_for]
        @relation_method = name.to_s.parameterize.underscore

        hide_on(:edit, :new) if polymorphic_as.present?
      end

      def value
        super(polymorphic_as)
      end

      def options
        target_resource.model_class.all.map do |model|
          {
            value: model.id,
            label: model.send(target_resource.class.title)
          }
        end
      end

      def database_value
        target_resource.id
      end

      def foreign_key
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
        foreign_key.to_sym
      end

      def target_resource
        return App.get_resource_by_model_name(polymorphic_for) if polymorphic_for.present?

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
