class TeamPolicy < ApplicationPolicy
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

  def avo_search?
    true
  end

  # Team members association
  # index? method
  def view_team_members?
    # record.class should be Team
    TestBuddy.hi "view_team_members?->#{record.class}"
    true
  end

  def show_team_members?
    # record.class should be User
    TestBuddy.hi "show_team_members?->#{record.class}"
    true
  end

  def create_team_members?
    # record.class should be Team
    TestBuddy.hi "create_team_members?->#{record.class}"
    true
  end

  def destroy_team_members?
    # record.class should be User
    TestBuddy.hi "destroy_team_members?->#{record.class}"
    true
  end

  def edit_team_members?
    # record.class should be User
    TestBuddy.hi "edit_team_members?->#{record.class}"
    Pundit.policy!(user, record).edit?
  end

  def attach_team_members?
    # record.class should be Team
    TestBuddy.hi "attach_team_members?->#{record.class}"
    true
  end

  def detach_team_members?
    # record.class should be User
    TestBuddy.hi "detach_team_members?->#{record.class}"
    true
  end

  def act_on_team_members?
    # record.class should be Team
    TestBuddy.hi "act_on_team_members?->#{record.class}"
    true
  end

  # Actions
  def act_on?
    false
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
