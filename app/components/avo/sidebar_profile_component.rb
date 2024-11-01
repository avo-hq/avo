# frozen_string_literal: true

class Avo::SidebarProfileComponent < Avo::BaseComponent
  prop :user

  delegate :main_app, to: :helpers

  def avatar
    if @user.respond_to?(:avatar) && @user.avatar.present?
      @user.avatar
    else
      ""
    end
  end

  def name
    if @user.respond_to?(:name) && @user.name.present?
      @user.name
    elsif @user.respond_to?(:email) && @user.email.present?
      @user.email
    elsif @user.respond_to?(:email_address) && @user.email_address.present?
      @user.email_address
    else
      "Avo user"
    end
  end

  def title
    if @user.respond_to?(:avo_title) && @user.avo_title.present?
      @user.avo_title
    else
      ""
    end
  end

  def sign_out_method
    :delete
  end

  def sign_out_path
    return Avo.configuration.sign_out_path_name if Avo.configuration.sign_out_path_name.present?
    return :session_path if possibly_rails_authentication?

    default_sign_out_path
  end

  def default_sign_out_path
    default_path = "destroy_#{Avo.configuration.current_user_resource_name}_session_path".to_sym

    default_path if main_app.respond_to?(default_path)
  end

  def can_sign_out_user?
    sign_out_path.present? && main_app.respond_to?(sign_out_path&.to_sym)
  end

  def possibly_rails_authentication?
    defined?(Authentication) && Authentication.private_instance_methods.include?(:require_authentication) && Authentication.private_instance_methods.include?(:authenticated?)
  end
end
