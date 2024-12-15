module Avo
  class PluginManager
    attr_reader :plugins
    # attr_reader :engines

    alias_method :all, :plugins

    def initialize
      puts ["new PluginManager->"].inspect
      @plugins = []
      @engines = []
    end

    def engines=(value)
      puts ["setter engines=->", value].inspect
      @engines = value
    end

    def engines
      puts ["getter engines->", @engines].inspect
      @engines
    end

    def register(name, priority: 10)
      @plugins << Plugin.new(name:, priority: priority)
    end

    def register_field(method_name, klass)
      # Avo.boot method is executed multiple times.
      # During the first run, it correctly loads descendants of Avo::Fields::Base.
      # Plugins are then loaded, introducing additional descendants to Avo::Fields::Base.
      # On subsequent runs, Avo::Fields::Base descendants now include these plugin fields.
      # This field_name_attribute assign forces the field name to retain the registered name instead of being computed dynamically from the field class.
      klass.field_name_attribute = method_name
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

    def mount_engine(klass, **options)
      puts ["mount_engine->", klass, options].inspect
      @engines << { klass:, options: }
    end
  end

  def self.plugin_manager
    @plugin_manager ||= PluginManager.new
  end
end
