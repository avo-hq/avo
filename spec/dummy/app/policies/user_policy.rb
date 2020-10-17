class UserPolicy < ApplicationPolicy
  def index?
    user.is_admin?
  end

  def show?
    user.is_admin?
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end
end
