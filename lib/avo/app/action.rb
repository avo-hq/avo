module Avo
  module Actions
    class Action
      # @todo: add redirect helpers to actions responses
      attr_accessor :name
      attr_accessor :message
      attr_accessor :default
      attr_accessor :theme
      attr_accessor :confirm_text
      attr_accessor :cancel_text
      # response: {
      #   message: String
      #   message_type: success | error
      #   type: reload | reload_resources | redirect | http_redirect | open_in_new_tab | download
      #   path: String
      #   filename: String
      # }
      attr_accessor :response
      attr_accessor :no_confirmation
      attr_accessor :model
      attr_accessor :resource

      @@default = nil

      class << self
        @@fields = {}

        def fields(&block)
          @@fields[self] ||= []
          yield
        end

        def get_fields
          @@fields[self] or []
        end

        def add_field(action, field)
          @@fields[action].push field
        end
      end

      def initialize
        @name ||= name
        @message ||= I18n.t('avo.are_you_sure_you_want_to_run_this_option')
        @default ||= ''
        @fields ||= []
        @confirm_text = I18n.t('avo.run')
        @cancel_text = I18n.t('avo.cancel')
        @response ||= {}
        @response[:message_type] ||= :notice
        @response[:message] ||= I18n.t('avo.action_ran_successfully')
        @theme ||= 'success'
        @no_confirmation ||= false
      end

      def render_response
        fields = get_fields.map { |field| field.fetch_for_action(model, resource) }

        {
          id: id,
          name: name,
          fields: fields,
          message: message,
          theme: theme,
          confirm_text: confirm_text,
          cancel_text: cancel_text,
          default: default,
          action_class: self.class.to_s,
          no_confirmation: no_confirmation,
        }
      end

      def set_model(model)
        @model = model
      end

      def set_resource(resource)
        @resource = resource
      end

      def handle_action(request, models, raw_fields)
        avo_fields = get_fields.map { |field| [field.id, field] }.to_h

        if raw_fields.present?
          fields = raw_fields.to_unsafe_h.map do |name, value|
            [name, avo_fields[name.to_sym].resolve_attribute(value)]
          end

          fields = fields.to_h
        else
          fields = {}
        end

        result = self.handle request, models, fields

        self
      end

      def id
        self.class.name.underscore.gsub '/', '_'
      end

      def name
        self.class.name.demodulize.underscore.humanize(keep_id_suffix: true)
      end

      def succeed(text)
        self.response[:message_type] = :notice
        self.response[:message] = text

        self
      end

      def fail(text)
        self.response[:message_type] = :alert
        self.response[:message] = text

        self
      end

      def redirect_to(path = nil, &block)
        self.response[:type] = :redirect
        if block.present?
          self.response[:path] = block
        else
          self.response[:path] = path
        end

        self
      end

      def reload
        self.response[:type] = :reload

        self
      end

      def download(path, filename)
        self.response[:type] = :download
        self.response[:path] = path
        self.response[:filename] = filename

        self
      end

      def get_fields
        self.class.get_fields
      end
    end
  end
end
