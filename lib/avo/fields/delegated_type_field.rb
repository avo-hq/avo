module Avo
  module Fields
    class DelegatedTypeField < BaseField
      # def initialize(id, **args, &block)
      #   super(id, **args, &block)
      # end

      def label
        return if target_resource.blank?

        target_resource.new(record: value)&.record_title
      end


      def target_resource
        Avo.resource_manager.get_resource_by_model_class(value.class)
        # return use_resource if use_resource.present?

        # if is_polymorphic?
        #   if value.present?
        #     return get_resource_by_model_class(value.class)
        #   else
        #     return nil
        #   end
        # end

        # reflection_key = polymorphic_as || id

        # if @record._reflections[reflection_key.to_s].klass.present?
        #   get_resource_by_model_class(@record._reflections[reflection_key.to_s].klass.to_s)
        # elsif @record._reflections[reflection_key.to_s].options[:class_name].present?
        #   get_resource_by_model_class(@record._reflections[reflection_key.to_s].options[:class_name])
        # else
        #   App.get_resource_by_name reflection_key.to_s
        # end
      end

      def type_input_foreign_key
        "#{foreign_key}_type"
      end

      def id_input_foreign_key
        "#{foreign_key}_id"
      end

      def foreign_key
        id
      end
    end
  end
end
