class PhotoCommentPolicy < ApplicationPolicy
  def index?
    false
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

  [:upload, :download, :delete].each do |action|
    define_method "#{action}_photo?" do
      true
    end
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
