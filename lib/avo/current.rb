class Avo::Current < ActiveSupport::CurrentAttributes
  # if Rails.env.development?
  # singleton_class.attr_accessor :previous_attributes
  # before_reset {
  #   puts ["before_reset->", self.previous_attributes].inspect
  #   if attributes.present?
  #     puts ["has attributes->"].inspect
  #     self.previous_attributes = attributes
  #   end
  #   puts ["before_reset->", self.previous_attributes].inspect
  # }

  # attr_accessor :previous_attributes

  # def previous_attributes=(value)
  #   @previous_attributes = value
  # end
  # end

  attribute :app
  attribute :license
  attribute :context, :user, :view_context
  attribute :error_manager
  attribute :resource_manager
  attribute :tool_manager
  attribute :plugin_manager
  attribute :locale

  # Protect from error #<RuntimeError: Missing rack.input> when request is ActionDispatch::Request.empty
  def params
    request.params
  rescue
    {}
  end

  def request
    view_context&.request || ActionDispatch::Request.empty
  end
end
