class UserPolicy < ApplicationPolicy
  def index?
    current_user.is_admin?
  end
end
