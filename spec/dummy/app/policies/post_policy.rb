class PostPolicy < ApplicationPolicy
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

  def act_on?
    true
  end

  def upload_attachments?
    true
  end

  def download_attachments?
    true
  end

  def delete_attachments?
    true
  end

  def view_comments?
    true
  end

  def edit_comments?
    true
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
