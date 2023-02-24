module FieldExtensions
  # Include all helpers
  helper_names = ActionController::Base.all_helpers_from_path Rails.root.join("app", "helpers")
  helpers = ActionController::Base.modules_for_helpers helper_names

  helpers.each do |helper|
    send(:include, helper)
  end
end
