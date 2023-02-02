module HomeHelper
  def extract_excerpt(body)
    ActionView::Base.full_sanitizer.sanitize(body).truncate 120
  end
end
