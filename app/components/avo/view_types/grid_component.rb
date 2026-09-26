# frozen_string_literal: true

class Avo::ViewTypes::GridComponent < Avo::ViewTypes::BaseViewTypeComponent
  # Resolved once per request and reused for every card's cache key. The
  # index-level resource is the same class as each row's, so a per-resource
  # `cache_context` override is honored.
  def cache_context
    @cache_context ||= @resource.cache_context
  end
end
