class UserPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def edit?
    update?
  end

  def update?
    true
  end

  def create?
    true
  end

  def new?
    create?
  end

  def destroy?
    true
  end

  def attach_post?
    true
  end

  def detach_post?
    true
  end

  def attach_project?
    true
  end

  def detach_project?
    true
  end

  def attach_team?
    true
  end

  def detach_team?
    true
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
