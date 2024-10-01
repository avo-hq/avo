module Avo
  class PluginManager
    attr_reader :plugins

    alias_method :all, :plugins

    def initialize
      @plugins = []
    end

    def register(name, priority: 10)
      @plugins << Plugin.new(name:, priority: priority)
    end

    def boot_plugins
      Avo.plugin_manager.all.sort_by(&:priority).each do |plugin|
        plugin.klass.boot
      end
    end

    def init_plugins
      Avo.plugin_manager.all.sort_by(&:priority).each do |plugin|
        plugin.klass.init
      end
    end

    def register_field(method_name, klass)
      Avo.field_manager.load_field method_name, klass
    end

    def register_resource_tool
    end

    def register_tool
    end

    def as_json(*arg)
      plugins.map do |plugin|
        {
          klass: plugin.to_s,
          priority: plugin.priority,
        }
      end
    end

    def to_s
      plugins.map do |plugin|
        plugin.to_s
      end.join(",")
    rescue
      "Failed to fetch plugins."
    end

    def installed?(name)
      plugins.any? do |plugin|
        plugin.name.to_s == name.to_s
      end
    end
  end

  def self.plugin_manager
    @plugin_manager ||= PluginManager.new
  end
end
