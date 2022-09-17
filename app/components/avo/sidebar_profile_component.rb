# frozen_string_literal: true

class Avo::SidebarProfileComponent < ViewComponent::Base
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def avatar
    if user.respond_to?(:avatar) && user.avatar.present?
      user.avatar
    else
      ""
    end
  end

  def name
    if user.respond_to?(:name) && user.name.present?
      user.name
    elsif user.respond_to?(:email) && user.email.present?
      user.email
    else
      "Avo user"
    end
  end

  def title
    if user.respond_to?(:avo_title) && user.avo_title.present?
      user.avo_title
    else
      ""
    end
  end

  def destroy_user_session_path
    "destroy_#{Avo.configuration.current_user_resource_name}_session_path".to_sym
  end

  def can_destroy_user?
    helpers.main_app.respond_to?(destroy_user_session_path)
  end
end
