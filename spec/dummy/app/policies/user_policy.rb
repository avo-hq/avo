class UserPolicy < ApplicationPolicy
  def view_any?
    user.is_admin?
    false
  end
end
