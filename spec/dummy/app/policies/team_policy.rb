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

  # Attachments
  def upload_attachments?
    true
  end

  def download_attachments?
    true
  end

  def delete_attachments?
    true
  end

  # Team members association
  # index? method
  def view_team_members?
    true
  end

  def show_team_members?
    true
  end

  def create_team_members?
    true
  end

  def destroy_team_members?
    true
  end

  def edit_team_members?
    Pundit.policy!(user, record).edit?
  end

  def attach_team_members?
    true
  end

  def detach_team_members?
    true
  end

  def act_on_team_members?
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
