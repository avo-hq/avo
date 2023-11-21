module Avo
  class AssetManager
    include ActionView::Helpers::AssetTagHelper

    attr_reader :stylesheets
    attr_reader :javascripts

    def initialize
      @stylesheets = []
      @javascripts = []
    end

    def reset
      @stylesheets = []
      @javascripts = []
    end

    def add_stylesheet(path)
      @stylesheets.push path
    end

    def add_javascript(path)
      @javascripts.push path
    end
  end

  def self.asset_manager
    @manager ||= AssetManager.new
  end
end
