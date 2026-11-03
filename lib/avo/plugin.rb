module Avo
  class Plugin
    attr_reader :name
    attr_reader :priority
    attr_reader :registered_from

    delegate :namespace, :engine, to: :class

    def initialize(*, name:, priority:, registered_from: nil, **, &block)
      @name = name
      @priority = priority
      @registered_from = registered_from
    end

    def to_s
      "#{name}-#{version}"
    end

    def hotkeys
      @hotkeys ||= []
    end

    # The namespace comes from the gem name (avo-dynamic_filters => dynamic_filters) rather than the
    # plugin, so it can't drift from the gem the way some locale roots did, or shadow core's IDs.
    def register_hotkey(action, default:, label:, section:, scopes: [:global])
      namespace = name.to_s.delete_prefix("avo-")
      if Avo::Hotkeys.core_namespaces.include?(namespace)
        raise ArgumentError, "Plugin #{name} can't register hotkeys: \"#{namespace}\" is a core hotkey namespace."
      end

      hotkeys << Avo::Hotkeys.entry("#{namespace}.#{action}", default, label, section:, scopes:)
      self
    end

    # The real gem name this plugin ships in (e.g. `avo-rhino_field`), as opposed
    # to the nickname it registered under (e.g. `:rhino`). Resolved by matching
    # the file that called `register` against the gems in the bundle, so it works
    # no matter how the plugin registered and even when the gem isn't `avo-*`.
    # Returns nil when the owning gem can't be found in the bundle.
    def gem_name
      return @gem_name if defined?(@gem_name)

      @gem_name = registered_gem&.name
    end

    # Installed version of this plugin's gem, resolved from the Bundler spec via
    # the registration callsite. Falls back to the class-level VERSION constant.
    def version
      return @version if defined?(@version)

      @version = registered_gem&.version&.to_s || self.class.version
    end

    private

    def registered_gem
      return if registered_from.blank?

      Bundler.load.specs
        .select { |spec| registered_from.start_with?("#{spec.full_gem_path}/") }
        .max_by { |spec| spec.full_gem_path.length }
    end

    class << self
      def name
        return gemspec.name if gemspec.present?

        to_s.split("::").first
      end

      def version
        "#{namespace}::VERSION".safe_constantize
      end

      def engine
        "#{namespace}::Engine".safe_constantize
      end

      def namespace
        modules = to_s.split("::")
        modules.pop
        modules.join("::")
      end

      def gemspec
        return if engine.blank?

        gemspec_path = Dir["#{engine.root}/*.gemspec"].first

        Gem::Specification.load(gemspec_path)
      end
    end
  end
end
