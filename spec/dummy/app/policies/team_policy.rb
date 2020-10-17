class TeamPolicy < ApplicationPolicy
  def index?
    user.is_admin?
    true
  end

  def show?
    # abort [user, record].inspect
    user.is_admin?
    false
  end

  def create?
    false
  end

  def update?
    # abort [user, record].inspect
    !record.name.include? 'Tesla'
    false
  end

  def destroy?
    false
  end
end
