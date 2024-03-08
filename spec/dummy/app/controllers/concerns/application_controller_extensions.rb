module ApplicationControllerExtensions
  extend ActiveSupport::Concern

  def extra_added_method
    puts ["extra_added_method->"].inspect
  end
end
