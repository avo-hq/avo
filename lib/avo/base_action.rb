module Avo
  class BaseAction
    class_attribute :name, default: self.class.to_s.demodulize.underscore.humanize(keep_id_suffix: true)
    class_attribute :message
    class_attribute :confirm_text
    class_attribute :cancel_text
    class_attribute :no_confirmation, default: false
    class_attribute :fields_loader

    attr_accessor :response
    attr_accessor :model
    attr_accessor :resource
    attr_accessor :user

    class << self
      def fields(&block)
        self.fields_loader ||= Avo::Loaders::FieldsLoader.new

        yield(fields_loader)
      end

      def context
        App.context
      end
    end

    def initialize
      self.class.message ||= I18n.t('avo.are_you_sure_you_want_to_run_this_option')
      self.class.confirm_text ||= I18n.t('avo.run')
      self.class.cancel_text ||= I18n.t('avo.cancel')

      @response ||= {}
      @response[:message_type] ||= :notice
      @response[:message] ||= I18n.t('avo.action_ran_successfully')
    end

    def get_fields(view_type: :table)
      get_field_definitions.map do |field|
        field.hydrate(action: self, model: @model)
      end
      .select do |field|
        field.can_see.present? ? field.can_see.call : true
      end
    end

    def get_field_definitions
      return [] if self.class.fields_loader.blank?

      self.class.fields_loader.bag.map do |field|
        field.hydrate(action: self)
      end
    end

    def hydrate(model: nil, resource: nil, user: nil)
      @model = model if model.present?
      @resource = resource if resource.present?
      @user = user if user.present?

      self
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

    def param_id
      self.class.to_s.demodulize.underscore.gsub '/', '_'
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
  end
end
