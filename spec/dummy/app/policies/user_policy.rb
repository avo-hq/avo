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

  def attach_posts?
    true
  end

  def detach_posts?
    true
  end

  def attach_projects?
    true
  end

  def detach_projects?
    true
  end

  def attach_teams?
    true
  end

  def detach_teams?
    true
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
