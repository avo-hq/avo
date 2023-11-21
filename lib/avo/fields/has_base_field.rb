module Avo
  module Fields
    class HasBaseField < BaseField
      include Avo::Fields::Concerns::IsSearchable
      include Avo::Fields::Concerns::UseResource

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

      def field_resource
        resource || Avo.resource_manager.get_resource_by_model_class(@record.class)
      end

      def turbo_frame
        "#{self.class.name.demodulize.to_s.underscore}_#{display}_#{frame_id}"
      end

      def frame_url
        Avo::Services::URIService.parse(field_resource.record_path)
          .append_path(id.to_s)
          .append_query(query_params)
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
        target_resource.new(record: value, view: view, user: user).record_title
      rescue
        nil
      end

      def target_resource
        if @record._reflections[id.to_s].klass.present?
          Avo.resource_manager.get_resource_by_model_class @record._reflections[id.to_s].klass.to_s
        elsif @record._reflections[id.to_s].options[:class_name].present?
          Avo.resource_manager.get_resource_by_model_class @record._reflections[id.to_s].options[:class_name]
        else
          Avo.resource_manager.get_resource_by_name id.to_s
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
      def component_for_view(view = Avo::ViewInquirer.new("index"))
        view = Avo::ViewInquirer.new("show") if view.in? %w[new create update edit]

        super view
      end

      def authorized?
        method = "view_#{id}?".to_sym
        service = field_resource.authorization

        if service.has_method? method
          service.authorize_action(method, raise_exception: false)
        else
          true
        end
      end

      def default_name
        use_resource&.name || super
      end

      def query_params
        {
          turbo_frame: turbo_frame,
          view: view
        }
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
