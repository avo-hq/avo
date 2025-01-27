module Avo
  class Plugin
    attr_reader :name
    attr_reader :priority

    delegate :version, :namespace, :engine, to: :class

    def initialize(*, name:, priority:, **, &block)
      @name = name
      @priority = priority
    end

    def to_s
      "#{name}-#{version}"
    end

    class << self
      def name
        return gemspec.name if gemspec.present?

        self.to_s.split("::").first
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

        Gem::Specification::load(gemspec_path)
      end
    end
  end
end
