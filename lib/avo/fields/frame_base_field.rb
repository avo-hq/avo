module Avo
  module Fields
    class FrameBaseField < BaseField
      include Avo::Fields::Concerns::UseResource
      include Avo::Fields::Concerns::ReloadIcon
      include Avo::Fields::Concerns::LinkableTitle
      include Avo::Concerns::HasDescription

      attr_reader :nested_limit

      def initialize(id, **args, &block)
        super(id, **args, &block)

        @use_resource = args[:use_resource]
        @reloadable = args[:reloadable]
        @linkable = args[:linkable]
        @description = args[:description]
        @nested_on = Array.wrap(args[:nested_on])
        @nested_limit = args[:nested_limit]
      end

      def field_resource
        resource || get_resource_by_model_class(@record.class)
      end

      def turbo_frame
        "#{self.class.name.demodulize.to_s.underscore}_show_#{frame_id}"
      end

      def frame_url(add_turbo_frame: true)
        Avo::Services::URIService.parse(field_resource.record_path)
          .append_path(id.to_s)
          .append_query(query_params(add_turbo_frame:))
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
        reflection = @record.class.reflect_on_association(association_name)

        if reflection.klass.present?
          get_resource_by_model_class(reflection.klass.to_s)
        elsif reflection.options[:class_name].present?
          get_resource_by_model_class(reflection.options[:class_name])
        else
          Avo.resource_manager.get_resource_by_name association_name
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
      # has_one have nested component on all views
      # has_many and has_and_belongs_to_many have nested component on new and create views
      def component_for_view(view = Avo::ViewInquirer.new("index"))
        view = Avo::ViewInquirer.new(view)

        return Avo::Fields::Common::NestedFieldComponent if nested_on?(view)

        return super(Avo::ViewInquirer.new("show")) if view.edit?

        super(view)
      end

      def nested_on?(view)
        return false if view.display || @nested_on.nil?

        view = if view.create?
          "new"
        elsif view.update?
          "edit"
        else
          view
        end

        @nested_on.map(&:to_s).include?(view)
      end

      def authorized?
        return true unless Avo.configuration.authorization_enabled?

        method = :"view_#{id}?"
        service = field_resource.authorization

        if service.has_method? method
          service.authorize_action(method, raise_exception: false)
        else
          !Avo.configuration.explicit_authorization
        end
      end

      def default_name
        use_resource&.name || super
      end

      def association_name
        @association_name ||= (@for_attribute || id).to_s
      end

      def query_params(add_turbo_frame: true)
        {
          view:,
          for_attribute: @for_attribute,
          turbo_frame: add_turbo_frame ? turbo_frame : nil
        }.compact
      end

      def resource_class(params)
        return use_resource if use_resource.present?

        return Avo.resource_manager.get_resource_by_name @id.to_s if @array

        reflection = @record.class.reflect_on_association(@for_attribute || params[:related_name])

        reflected_model = reflection.klass

        Avo.resource_manager.get_resource_by_model_class reflected_model
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
