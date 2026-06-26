module Avo
  class Plugin
    attr_reader :name
    attr_reader :priority
    attr_reader :registered_from

    delegate :version, :namespace, :engine, to: :class

    def initialize(*, name:, priority:, registered_from: nil, **, &block)
      @name = name
      @priority = priority
      @registered_from = registered_from
    end

    def to_s
      "#{name}-#{version}"
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

    # The actual installed version of the gem that ships this plugin, resolved
    # from the Bundler spec. More reliable than the class-level VERSION constant
    # lookup because plugins are instances of Avo::Plugin (not subclasses).
    def gem_version
      return @gem_version if defined?(@gem_version)

      @gem_version = registered_gem&.version&.to_s
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
