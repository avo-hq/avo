module Avo
  module Fields
    class HasBaseField < BaseField
      attr_accessor :display
      attr_accessor :scope
      attr_accessor :attach_scope
      attr_accessor :description

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @scope = args[:scope].present? ? args[:scope] : nil
        @attach_scope = args[:attach_scope].present? ? args[:attach_scope] : nil
        @display = args[:display].present? ? args[:display] : :show
        @searchable = args[:searchable] == true
        @description = args[:description]
      end

      def searchable
        @searchable && ::Avo::App.license.has_with_trial(:searchable_associations)
      end

      def resource
        Avo::App.get_resource_by_model_name @model.class
      end

      def turbo_frame
        "#{self.class.name.demodulize.to_s.underscore}_#{display}_#{id}"
      end

      def frame_url
        Avo::Services::URIService.parse(@resource.record_path)
          .append_path(id.to_s)
          .append_query(turbo_frame: turbo_frame.to_s).to_s
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

      def target_resource
        if @model._reflections[id.to_s].klass.present?
          Avo::App.get_resource_by_model_name @model._reflections[id.to_s].klass.to_s
        elsif @model._reflections[id.to_s].options[:class_name].present?
          Avo::App.get_resource_by_model_name @model._reflections[id.to_s].options[:class_name]
        else
          Avo::App.get_resource_by_name id.to_s
        end
      end

      def placeholder
        @placeholder || I18n.t("avo.choose_an_option")
      end
    end
  end
end
