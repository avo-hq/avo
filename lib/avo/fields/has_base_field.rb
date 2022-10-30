module Avo
  module Fields
    class HasBaseField < BaseField
      attr_accessor :display
      attr_accessor :scope
      attr_accessor :attach_scope
      attr_accessor :description
      attr_accessor :discreet_pagination
      attr_accessor :hide_search_input
      attr_reader :link_to_child_resource

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @scope = args[:scope].present? ? args[:scope] : nil
        @attach_scope = args[:attach_scope].present? ? args[:attach_scope] : nil
        @display = args[:display].present? ? args[:display] : :show
        @searchable = args[:searchable] == true
        @hide_search_input = args[:hide_search_input] || false
        @description = args[:description]
        @use_resource = args[:use_resource] || nil
        @discreet_pagination = args[:discreet_pagination] || false
        @link_to_child_resource = args[:link_to_child_resource] || false
      end

      def searchable
        @searchable && ::Avo::App.license.has_with_trial(:searchable_associations)
      end

      def use_resource
        App.get_resource @use_resource
      end

      def resource
        @resource || Avo::App.get_resource_by_model_name(@model.class)
      end

      def turbo_frame
        "#{self.class.name.demodulize.to_s.underscore}_#{display}_#{frame_id}"
      end

      def frame_url
        Avo::Services::URIService.parse(@resource.record_path)
          .append_path(id.to_s)
          .append_query(turbo_frame: turbo_frame.to_s)
          .to_s
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

      def has_own_panel?
        true
      end

      def visible_in_reflection?
        false
      end

      # Adds the view override component
      # has_one, has_many, has_and_belongs_to_many fields don't have edit views
      def component_for_view(view = :index)
        view = :show if view.in? [:new, :create, :update, :edit]

        super view
      end

      def authorized?
        method = "view_#{id}?".to_sym
        service = resource.authorization

        if service.has_method? method
          service.authorize_action(method, raise_exception: false)
        else
          true
        end
      end

      def default_name
        use_resource&.name || super
      end

      private

      def frame_id
        use_resource.present? ? use_resource.route_key.to_sym : @id
      end

      def default_view
        Avo.configuration.skip_show_view ? :edit : :show
      end
    end
  end
end
