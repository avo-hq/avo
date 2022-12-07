class Avo::Current < ActiveSupport::CurrentAttributes
  attribute :params, :request, :context, :current_user, :view_context
  attribute :license
end
