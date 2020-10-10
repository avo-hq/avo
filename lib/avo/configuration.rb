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

    def initialize
      @root_path = '/avo'
      @app_name = Rails.application.class.to_s.split("::").first
      @timezone = 'UTC'
      @per_page = 24
      @per_page_steps = [12, 24, 48, 72]
      @via_per_page = 8
      @locale = 'us-US'
      @currency = 'USD'
      @default_view_type = :table
      @hide_resource_overview_component = false
      @hide_documentation_link = false
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
