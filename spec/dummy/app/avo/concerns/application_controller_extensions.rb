module ApplicationControllerExtensions
  extend ActiveSupport::Concern

  included do
    before_action :set_current
  end

  def set_current
    Current.user = current_user
  end
end
