module Avo
  class PluginManager
    attr_reader :plugins
    attr_accessor :engines

    alias_method :all, :plugins

    def initialize
      @plugins = []
      @engines = []
    end

    def reset
      @plugins = []
      @engines = []
    end

    def register(name, priority: 10)
      # Capture the file that called `register` so the plugin can later resolve
      # the gem it actually ships in. Plugins register under nicknames
      # (e.g. `:rhino` for `avo-rhino_field`), so the name alone isn't enough.
      registered_from = caller_locations(1, 1)&.first&.path

      @plugins << Plugin.new(name:, priority: priority, registered_from: registered_from)
    end

    def register_view_type(name, component:, icon:, active_icon:, translation_key: nil)
      Avo.view_type_manager.register(name, component:, icon:, active_icon:, translation_key:)
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

    # Register a custom menu DSL method (e.g. `form`) contributed by a plugin,
    # so it can be used inside `config.main_menu` and friends. Delegates to
    # avo-menu's builder when it's installed; a no-op otherwise, so plugins can
    # register unconditionally. The block is evaluated in the menu builder's
    # context, so it can call `link`, `resource`, etc. See
    # Avo::Menu::Builder.register_item.
    def register_menu_item(name, &block)
      return unless defined?(Avo::Menu::Builder)

      Avo::Menu::Builder.register_item(name, &block)
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
      @engines << {klass:, options:}
    end
  end

  def self.plugin_manager
    @plugin_manager ||= PluginManager.new
  end
end
