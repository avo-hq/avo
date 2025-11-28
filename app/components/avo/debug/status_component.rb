# frozen_string_literal: true

class Avo::Debug::StatusComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  def information_items
    @information_items ||= {
      license_key: Avo.configuration.license_key,
      ruby_version: RUBY_VERSION,
      rails_version: Rails::VERSION::STRING,
      environment: Rails.env,
      host: Avo::Current.request&.host,
      port: Avo::Current.request&.port,
      ip: Avo::Current.request&.ip,
      app_name: Avo.configuration.app_name,
    }.stringify_keys.except(*Avo.configuration.exclude_from_status)
  end
end
