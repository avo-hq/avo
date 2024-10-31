module Avo
  class BaseAction
    include Avo::Concerns::HasItems
    include Avo::Concerns::HasActionStimulusControllers
    include Avo::Concerns::Hydration

    class_attribute :name, default: nil
    class_attribute :message
    class_attribute :confirm_button_label
    class_attribute :cancel_button_label
    class_attribute :no_confirmation, default: false
    class_attribute :standalone, default: false
    class_attribute :visible
    class_attribute :may_download_file
    class_attribute :turbo
    class_attribute :authorize, default: true

    attr_accessor :view
    attr_accessor :response
    attr_accessor :record
    attr_accessor :resource
    attr_accessor :user
    attr_reader :arguments
    attr_reader :icon
    attr_reader :appended_turbo_streams
    attr_reader :records_to_reload

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
    delegate :link_arguments, to: :class

    class << self
      delegate :context, to: ::Avo::Current

      def form_data_attributes
        {
          turbo: turbo,
          turbo_frame: :_top
        }.compact
      end

      def to_param
        to_s
      end

      def link_arguments(resource:, arguments: {}, **args)
        path = Avo::Services::URIService.parse(resource.record&.persisted? ? resource.record_path : resource.records_path)
          .append_paths("actions")
          .append_query(
            **{
              action_id: to_param,
              arguments: encode_arguments(arguments),
              **args
            }.compact
          )
          .to_s

        [path, {turbo_frame: Avo::MODAL_FRAME_ID}]
      end

      # Encrypt the arguments so we can pass sensible data as a query param.
      # EncryptionService can generate special characters that can break the URL.
      # We use Base64 to encode the encrypted string so we can safely pass it as a query param and don't break the URL.
      def encode_arguments(arguments)
        return if arguments.blank?

        Base64.encode64 Avo::Services::EncryptionService.encrypt(
          message: arguments,
          purpose: :action_arguments
        )
      end

      def decode_arguments(arguments)
        return if arguments.blank?

        Avo::Services::EncryptionService.decrypt(
          message: Base64.decode64(arguments),
          purpose: :action_arguments
        )
      end
    end

    def action_name
      if name.present?
        return Avo::ExecutionContext.new(
          target: name,
          resource: @resource,
          record: @record,
          view: @view,
          arguments: @arguments
        ).handle
      end

      self.class.to_s.demodulize.underscore.humanize(keep_id_suffix: true)
    end

    def initialize(record: nil, resource: nil, user: nil, view: nil, arguments: {}, icon: :play)
      @record = record
      @resource = resource
      @user = user
      @view = Avo::ViewInquirer.new(view)
      @icon = icon
      @arguments = Avo::ExecutionContext.new(
        target: arguments,
        resource: resource,
        record: record
      ).handle.with_indifferent_access

      self.class.message ||= I18n.t("avo.are_you_sure_you_want_to_run_this_option")
      self.class.confirm_button_label ||= I18n.t("avo.run")
      self.class.cancel_button_label ||= I18n.t("avo.cancel")

      self.items_holder = Avo::Resources::Items::Holder.new

      @response ||= {}
      @response[:messages] = []

      if may_download_file.present?
        puts "[Avo->] WARNING! Since version 3.2.2 'may_download_file' is unecessary and deprecated on actions. Can be safely removed from #{self.class.name}"
      end
    end

    # Blank method
    def fields
    end

    def get_message
      Avo::ExecutionContext.new(
        target: self.class.message,
        resource: @resource,
        record: @record,
        view: @view,
        arguments: @arguments
      ).handle
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
      response[:type] = :keep_modal_open

      self
    end

    def close_modal
      response[:type] = :close_modal

      self
    end

    # def do_nothing
    alias_method :do_nothing, :close_modal

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

    def reload_record(records)
      # Force close modal to avoid default redirect to
      # Redirect is 100% not wanted when using reload_record
      close_modal

      @records_to_reload = Array(records)

      append_to_response -> {
        table_row_components = []
        header_fields = []

        @action.records_to_reload.each do |record|
          resource = @resource.dup
          resource.hydrate(record:, view: :index)
          resource.detect_fields
          row_fields = resource.get_fields(only_root: true)
          header_fields.concat row_fields
          table_row_components << resource.resolve_component(Avo::Index::TableRowComponent).new(
            resource: resource,
            header_fields: row_fields.map(&:table_header_label),
            fields: row_fields
          )
        end

        header_fields.uniq!(&:table_header_label)

        header_fields_ids = header_fields.map(&:table_header_label)

        table_row_components.map.with_index do |table_row_component, index|
          table_row_component.header_fields = header_fields_ids
          turbo_stream.replace(
            "avo/index/table_row_component_#{@action.records_to_reload[index].to_param}",
            table_row_component
          )
        end
      }
    end

    # def reload_records
    alias_method :reload_records, :reload_record

    def navigate_to_action(action, **kwargs)
      response[:type] = :navigate_to_action
      response[:action] = action
      response[:navigate_to_action_args] = kwargs

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
        action: self,
        resource: @resource,
        view: @view,
        arguments: arguments
      ).handle
    end

    def append_to_response(turbo_stream)
      @appended_turbo_streams = turbo_stream
    end

    def enabled?
      self.class.standalone || @record&.persisted?
    end

    def disabled?
      !enabled?
    end

    private

    def add_message(body, type = :info)
      response[:messages] << {
        type: type,
        body: body&.truncate(320)
      }
    end
  end
end
