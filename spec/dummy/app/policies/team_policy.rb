class TeamPolicy < ApplicationPolicy
  def index?
    user.is_admin?
    true
  end

  def show?
    # abort [user, record].inspect
    user.is_admin?
    true
  end

  def create?
    true
  end

  def update?
    !record.name.include? 'Tesla'
    true
  end

  def destroy?
    true
  end
end
