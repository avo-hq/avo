module Avo
  module Fields
    class BelongsToField < BaseField
      def initialize(name, **args, &block)
        @defaults = {
          partial_name: "belongs-to-field",
          placeholder: I18n.t("avo.choose_an_option")
        }

        super(name, **args, &block)

        @meta[:searchable] = args[:searchable] == true
        @meta[:relation_method] = name.to_s.parameterize.underscore
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
          if @model.instance_of?(Class)
            @model.reflections[@meta[:relation_method]].foreign_key
          else
            @model.class.reflections[@meta[:relation_method]].foreign_key
          end
        elsif @resource.present?
          @resource.model_class.reflections[@meta[:relation_method]].foreign_key
        end
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
        if @model._reflections[id.to_s].klass.present?
          App.get_resource_by_model_name @model._reflections[id.to_s].klass.to_s
        elsif @model._reflections[id.to_s].options[:class_name].present?
          App.get_resource_by_model_name @model._reflections[id.to_s].options[:class_name]
        else
          App.get_resource_by_name id.to_s
        end
      end
    end
  end
end
