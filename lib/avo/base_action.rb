module Avo
  class BaseAction
    include Avo::Concerns::HasFields

    class_attribute :name, default: nil
    class_attribute :message
    class_attribute :confirm_button_label
    class_attribute :cancel_button_label
    class_attribute :no_confirmation, default: false
    class_attribute :model
    class_attribute :view
    class_attribute :user
    class_attribute :resource
    class_attribute :standalone, default: false
    class_attribute :visible
    class_attribute :may_download_file, default: false

    attr_accessor :response
    attr_accessor :model
    attr_accessor :resource
    attr_accessor :user

    delegate :view, to: :class
    delegate :context, to: ::Avo::App
    delegate :current_user, to: ::Avo::App
    delegate :params, to: ::Avo::App
    delegate :view_context, to: ::Avo::App
    delegate :avo, to: :view_context
    delegate :main_app, to: :view_context

    class << self
      delegate :context, to: ::Avo::App

      def form_data_attributes
        # We can't respond with a file download from Turbo se we disable it on the form
        if may_download_file
          {turbo: false, remote: false}
        else
          {"turbo-frame": "_top", "action-target": "form"}
        end
      end

      # We can't respond with a file download from Turbo se we disable close the modal manually after a while (it's a hack, we know)
      def submit_button_data_attributes
        if may_download_file
          {action: "click->modal#delayedClose"}
        else
          {}
        end
      end
    end

    def action_name
      return name if name.present?

      self.class.to_s.demodulize.underscore.humanize(keep_id_suffix: true)
    end

    def initialize(model: nil, resource: nil, user: nil, view: nil)
      self.class.model = model if model.present?
      self.class.resource = resource if resource.present?
      self.class.user = user if user.present?
      self.class.view = view if view.present?

      self.class.message ||= I18n.t("avo.are_you_sure_you_want_to_run_this_option")
      self.class.confirm_button_label ||= I18n.t("avo.run")
      self.class.cancel_button_label ||= I18n.t("avo.cancel")

      @response ||= {}
      @response[:messages] = []
    end

    def get_attributes_for_action
      get_fields.map do |field|
        [field.id, field.value]
      end.to_h
    end

    def handle_action(**args)
      models, fields, current_user, resource = args.values_at(:models, :fields, :current_user, :resource)
      # Fetching the field definitions and not the actual fields (get_fields) because they will break if the user uses a `visible` block and adds a condition using the `params` variable. The params are different in the show method and the handle method.
      action_fields = get_field_definitions.map { |field| [field.id, field] }.to_h

      # For some fields, like belongs_to, the id and database_id differ (user vs user_id).
      # That's why we need to fetch the database_id for when we process the action.
      action_fields_by_database_id = action_fields.map do |id, value|
        [value.database_id.to_sym, value]
      end.to_h

      if fields.present?
        processed_fields = fields.to_unsafe_h.map do |name, value|
          field = action_fields_by_database_id[name.to_sym]

          next if field.blank?

          [name, field.resolve_attribute(value)]
        end

        processed_fields = processed_fields.reject(&:blank?).to_h
      else
        processed_fields = {}
      end

      args = {
        fields: processed_fields.with_indifferent_access,
        current_user: current_user,
        resource: resource
      }

      args[:models] = models unless standalone

      handle(**args)

      self
    end

    def visible_in_view
      # Run the visible block if available
      return instance_exec(resource: self.class.resource, view: view, &visible) if visible.present?

      # Hide on the :new view by default
      return false if view == :new

      # Show on all other views
      true
    end

    def param_id
      self.class.to_s.demodulize.underscore.tr "/", "_"
    end

    def succeed(text)
      add_message text, :success

      self
    end

    def fail(text)
      add_message text, :error

      self
    end

    def inform(text)
      add_message text, :info

      self
    end

    def warn(text)
      add_message text, :warning

      self
    end

    # Add a placeholder silent message from when a user wants to do a redirect action or something similar
    def silent
      add_message nil, :silent

      self
    end

    def redirect_to(path = nil, &block)
      response[:type] = :redirect
      response[:path] = if block.present?
        block
      else
        path
      end

      self
    end

    def reload
      response[:type] = :reload

      self
    end

    def download(path, filename)
      response[:type] = :download
      response[:path] = path
      response[:filename] = filename

      self
    end

    # We're overriding this method to hydrate with the proper resource attribute.
    def hydrate_fields(model: nil, view: nil)
      fields.map do |field|
        field.hydrate(model: @model, view: @view, resource: resource)
      end

      self
    end

    private

    def add_message(body, type = :info)
      response[:messages] << {
        type: type,
        body: body
      }
    end
  end
end
