module Avo
  class BaseAction
    include Avo::Concerns::HasItems
    include Avo::Concerns::HasActionStimulusControllers

    class_attribute :name, default: nil
    class_attribute :message
    class_attribute :confirm_button_label
    class_attribute :cancel_button_label
    class_attribute :no_confirmation, default: false
    class_attribute :standalone, default: false
    class_attribute :visible
    class_attribute :may_download_file, default: false
    class_attribute :turbo
    class_attribute :authorize, default: true

    attr_accessor :view
    attr_accessor :response
    attr_accessor :record
    attr_accessor :resource
    attr_accessor :user
    attr_reader :arguments

    # TODO: find a differnet way to delegate this to the uninitialized Current variable
    delegate :context, to: Avo::Current
    def current_user
      Avo::Current.user
    end
    delegate :params, to: Avo::Current
    delegate :view_context, to: Avo::Current
    delegate :avo, to: :view_context
    delegate :main_app, to: :view_context
    delegate :to_param, to: :class

    class << self
      delegate :context, to: ::Avo::Current

      def form_data_attributes
        # We can't respond with a file download from Turbo se we disable it on the form
        if may_download_file
          {turbo: turbo || false, remote: false}
        else
          {turbo: turbo, turbo_frame: :_top}.compact
        end
      end

      # We can't respond with a file download from Turbo se we disable close the modal manually after a while (it's a hack, we know)
      def submit_button_data_attributes
        attributes = { action_target: "submit" }

        if may_download_file
          attributes[:action] = "click->modal#delayedClose"
        end

        attributes
      end

      def to_param
        to_s
      end

      def link_arguments(resource:, **args)
        path = Avo::Services::URIService.parse(resource.record.present? ? resource.record_path : resource.records_path)
          .append_paths("actions")
          .append_query(action_id: to_param, **args)
          .to_s

        data = {
          turbo_frame: "actions_show",
        }

        [path, data]
      end
    end

    def action_name
      return name if name.present?

      self.class.to_s.demodulize.underscore.humanize(keep_id_suffix: true)
    end

    def initialize(record: nil, resource: nil, user: nil, view: nil, arguments: {})
      @record = record
      @resource = resource
      @user = user
      @view = Avo::ViewInquirer.new(view)
      @arguments = Avo::ExecutionContext.new(
        target: arguments,
        resource: resource,
        record: record
      ).handle.with_indifferent_access

      self.class.message ||= I18n.t("avo.are_you_sure_you_want_to_run_this_option")
      self.class.confirm_button_label ||= I18n.t("avo.run")
      self.class.cancel_button_label ||= I18n.t("avo.cancel")

      self.items_holder = Avo::Resources::Items::Holder.new
      fields

      @response ||= {}
      @response[:messages] = []
    end

    # Blank method
    def fields
    end

    def get_message
      Avo::ExecutionContext.new(target: self.class.message, record: @record, resource: @resource).handle
    end

    def handle_action(**args)
      processed_fields = if args[:fields].present?
        # Fetching the field definitions and not the actual fields (get_fields) because they will break if the user uses a `visible` block and adds a condition using the `params` variable. The params are different in the show method and the handle method.
        action_fields = get_field_definitions.map do |field|
          field.hydrate(resource: @resource)

          [field.id, field]
        end.to_h

        # For some fields, like belongs_to, the id and database_id differ (user vs user_id).
        # That's why we need to fetch the database_id for when we process the action.
        action_fields_by_database_id = action_fields.map do |id, value|
          [value.database_id.to_sym, value]
        end.to_h

        args[:fields].to_unsafe_h.map do |name, value|
          field = action_fields_by_database_id[name.to_sym]

          next if field.blank?

          [name, field.resolve_attribute(value)]
        end.reject(&:blank?).to_h
      else
        {}
      end

      handle(
        fields: processed_fields.with_indifferent_access,
        current_user: args[:current_user],
        resource: args[:resource],
        records: args[:query],
        query: args[:query]
      )

      self
    end

    def visible_in_view(parent_resource: nil)
      return false unless authorized?

      if visible.blank?
        # Hide on the :new view by default
        return false if view.new?

        # Show on all other views
        return true
      end

      # Run the visible block if available
      Avo::ExecutionContext.new(
        target: visible,
        params: params,
        parent_resource: parent_resource,
        resource: @resource,
        view: @view,
        arguments: arguments
      ).handle
    end

    def succeed(text)
      add_message text, :success

      self
    end

    def error(text)
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

    def keep_modal_open
      response[:keep_modal_open] = true

      self
    end

    # Add a placeholder silent message from when a user wants to do a redirect action or something similar
    def silent
      add_message nil, :silent

      self
    end

    def redirect_to(path = nil, **args, &block)
      response[:type] = :redirect
      response[:redirect_args] = args
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

    def authorized?
      Avo::ExecutionContext.new(
        target: authorize,
        action: self
      ).handle
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
