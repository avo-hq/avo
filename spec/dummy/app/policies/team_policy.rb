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
  def create_team_members?
    false
  end

  def destroy_team_members?
    false
  end

  def view_team_members?
    false
  end

  def edit_team_members?
    false
  end

  def attach_team_members?
    false
  end

  def detach_team_members?
    false
  end

  def act_on_team_members?
    false
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
