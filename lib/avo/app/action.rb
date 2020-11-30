module Avo
  module Actions
    class Action
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
        @response[:message_type] ||= :success
        @response[:message] ||= I18n.t('avo.action_ran_successfully')
        @theme ||= 'success'
        @no_confirmation ||= false
      end

      def render_response(model, resource)
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
        self.response[:message_type] = :success
        self.response[:message] = text

        self
      end

      def fail(text)
        self.response[:message_type] = :error
        self.response[:message] = text

        self
      end

      def redirect(path)
        self.response[:type] = :redirect
        self.response[:path] = path

        self
      end

      def http_redirect(path)
        self.response[:type] = :http_redirect
        self.response[:path] = path

        self
      end

      def reload
        self.response[:type] = :reload

        self
      end

      def reload_resources
        self.response[:type] = :reload_resources

        self
      end

      def open_in_new_tab(path)
        self.response[:type] = :open_in_new_tab
        self.response[:path] = path

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
