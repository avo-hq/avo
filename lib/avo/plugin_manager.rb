module Avo
  class PluginManager
    attr_reader :plugins
    attr_reader :engines

    alias_method :all, :plugins

    def initialize
      @plugins = []
      @engines = []
      @building_plugins = []
      @building_engines = []
    end

    # Starts a re-registration cycle without touching the currently published
    # @plugins/@engines, so concurrent readers (e.g. mount_avo's route-drawing
    # loop) keep seeing the complete pre-reload list until #commit_reload
    # publishes the new one. Called by Avo.boot inside its Mutex, so only one
    # reload is ever building at a time.
    def begin_reload
      @building_plugins = []
      @building_engines = []
    end

    # Publishes the registrations collected since #begin_reload. Each of the
    # two reassignments below is individually an atomic pointer swap, so a
    # reader of .engines alone (or .plugins alone) always sees the complete
    # old list or the complete new one, never a partially rebuilt one. The
    # two fields are not published jointly -- a reader combining both in one
    # operation could observe them from different reload generations. No
    # current reader does that (mount_avo reads only .engines; installed?
    # reads only .plugins).
    def commit_reload
      @plugins = @building_plugins
      @engines = @building_engines
      # Reset to fresh arrays rather than nil: register/mount_engine must
      # stay callable even outside a begin_reload/commit_reload window --
      # e.g. avo-permissions calls Avo.plugin_manager.register at Rails
      # initializer time, before Avo.boot ever runs. Such a call is simply
      # discarded by the next #begin_reload rather than raising, matching
      # the pre-atomic-publish behavior where register/mount_engine never
      # crashed regardless of timing.
      @building_plugins = []
      @building_engines = []
    end

    def register(name, priority: 10)
      # Capture the file that called `register` so the plugin can later resolve
      # the gem it actually ships in. Plugins register under nicknames
      # (e.g. `:rhino` for `avo-rhino_field`), so the name alone isn't enough.
      registered_from = caller_locations(1, 1)&.first&.path

      @building_plugins << Plugin.new(name:, priority: priority, registered_from: registered_from)
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
      # Dedup by class so a plugin hook that (by bug) calls mount_engine
      # twice for the same engine within one boot can't leave a duplicate
      # entry for #commit_reload to publish.
      @building_engines.delete_if { |engine| engine[:klass] == klass }
      @building_engines << {klass:, options:}
    end
  end

  def self.plugin_manager
    @plugin_manager ||= PluginManager.new
  end
end
