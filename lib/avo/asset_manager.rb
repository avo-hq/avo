module Avo
  class AssetManager
    include ActionView::Helpers::AssetTagHelper

    attr_reader :stimulus_controllers

    def initialize
      @stylesheets = []
      @javascripts = []
      @stimulus_controllers = {}
    end

    def reset
      @stylesheets = []
      @javascripts = []
      @stimulus_controllers = {}
    end

    def add_stylesheet(path)
      @stylesheets.push path
    end

    def add_javascript(path)
      @javascripts.push path
    end

    def register_stimulus_controller(name, controller)
      @stimulus_controllers[name] = controller
    end

    def stylesheets
      @stylesheets.uniq
    end

    def javascripts
      @javascripts.uniq
    end
  end

  def self.asset_manager
    @manager ||= AssetManager.new
  end
end
