class PostDecorator < Draper::Decorator
  delegate_all

  # This is here to test the decorator in different scenarios
  def decorated_name
    name
  end

  def excerpt
    ActionView::Base.full_sanitizer.sanitize(body).truncate 130
  end
end
