class Avo::Current < ActiveSupport::CurrentAttributes
  attribute :resources
  attribute :fields
  attribute :dashboards
  attribute :cache_store
  attribute :request
  attribute :context
  attribute :license
  attribute :current_user
  # attribute :root_path
  attribute :view_context
  attribute :params
  attribute :translation_enabled
  attribute :error_messages
end

