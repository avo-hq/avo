module Avo
  class BaseAction
    extend FieldsCollector
    extend HasContext

    class_attribute :name, default: self.class.to_s.demodulize.underscore.humanize(keep_id_suffix: true)
    class_attribute :message
    class_attribute :confirm_button_label
    class_attribute :cancel_button_label
    class_attribute :no_confirmation, default: false
    class_attribute :model
    class_attribute :view
    class_attribute :user
    class_attribute :resource
    class_attribute :fields

    attr_accessor :response
    attr_accessor :model
    attr_accessor :resource
    attr_accessor :user
    attr_accessor :fields_loader

    def initialize(model: nil, resource: nil, user: nil)
      self.class.model = model if model.present?
      self.class.resource = resource if resource.present?
      self.class.user = user if user.present?

      self.class.message ||= I18n.t("avo.are_you_sure_you_want_to_run_this_option")
      self.class.confirm_button_label ||= I18n.t("avo.run")
      self.class.cancel_button_label ||= I18n.t("avo.cancel")

      @response ||= {}
      @response[:message_type] ||= :notice
      @response[:message] ||= I18n.t("avo.action_ran_successfully")
    end

    def context
      self.class.context
    end

    def get_field_definitions
      return [] if self.class.fields.blank?

      self.class.fields.map do |field|
        field.hydrate(action: self)
      end
    end

    def get_fields
      get_field_definitions.map do |field|
        field.hydrate(action: self, model: @model)
      end
        .select do |field|
        field.visible?
      end
    end

    def get_attributes_for_action
      get_fields.map do |field|
        [field.id, field.value]
      end
        .to_h
    end

    def handle_action(models:, fields:)
      avo_fields = get_fields.map { |field| [field.id, field] }.to_h

      if fields.present?
        processed_fields = fields.to_unsafe_h.map do |name, value|
          [name, avo_fields[name.to_sym].resolve_attribute(value)]
        end

        processed_fields = processed_fields.to_h
      else
        processed_fields = {}
      end

      handle models: models, fields: processed_fields

      self
    end

    def param_id
      self.class.to_s.demodulize.underscore.tr "/", "_"
    end

    def succeed(text)
      response[:message_type] = :notice
      response[:message] = text

      self
    end

    def fail(text)
      response[:message_type] = :alert
      response[:message] = text

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
  end
end
