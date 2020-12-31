module Avo
  class Configuration
    attr_accessor :root_path
    attr_accessor :app_name
    attr_accessor :timezone
    attr_accessor :per_page
    attr_accessor :per_page_steps
    attr_accessor :via_per_page
    attr_accessor :locale
    attr_accessor :currency
    attr_accessor :default_view_type
    attr_accessor :hide_resource_overview_component
    attr_accessor :hide_documentation_link
    attr_accessor :license
    attr_accessor :license_key
    attr_accessor :authorization_methods
    attr_accessor :authenticate
    attr_accessor :current_user

    def initialize
      @root_path = '/avo'
      @app_name = Rails.application.class.to_s.split('::').first.underscore.humanize(keep_id_suffix: true)
      @timezone = 'UTC'
      @per_page = 24
      @per_page_steps = [12, 24, 48, 72]
      @via_per_page = 8
      @locale = 'en-US'
      @currency = 'USD'
      @default_view_type = :table
      @hide_resource_overview_component = false
      @hide_documentation_link = false
      @license = 'community'
      @license_key = nil
      @current_user = proc {}
      @authenticate = proc {}
      @authorization_methods = {
        index: 'index?',
        show: 'show?',
        edit: 'edit?',
        new: 'new?',
        update: 'update?',
        create: 'create?',
        destroy: 'destroy?',
      }
    end

    def locale_tag
      ::ISO::Tag.new(locale)
    end

    def language_code
      begin
        locale_tag.language.code
      rescue => exception
        'en'
      end
    end

    def current_user_method(&block)
      @current_user = block if block.present?
    end

    def authenticate_with(&block)
      @authenticate = block if block.present?
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(config)
    @configuration = config
  end

  def self.configure
    yield configuration
  end
end
