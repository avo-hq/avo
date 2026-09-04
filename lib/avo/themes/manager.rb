module Avo
  module Themes
    # The theme registry, built once per boot from three static sources:
    # core's built-ins, the host app's `Avo::Themes::*` classes, and any
    # `Avo::BaseTheme` descendant a gem defined. Keyed by id; two themes with
    # one id raise at boot, naming both classes, because a silent "last wins"
    # is exactly how a gem's theme would shadow a local one unnoticed.
    class Manager
      attr_reader :themes

      def self.build
        new.tap(&:load)
      end

      def initialize
        @themes = {}
      end

      def load
        eager_load_local_themes

        candidates = Avo::BuiltinThemes.all + (Avo::BaseTheme.descendants - Avo::BuiltinThemes.all)
        candidates.select { |klass| live?(klass) }.each { |klass| register(klass) }
        self
      end

      def register(klass)
        id = klass.id
        existing = @themes[id]
        if existing && existing != klass
          raise ArgumentError, "Two themes claim the id #{id.inspect}: #{existing.name} and #{klass.name}. Set `self.id` on one of them."
        end

        @themes[id] = klass
      end

      # Every registered theme: built-ins in their shipped order, then local and
      # gem themes sorted by title.
      def all
        builtins = Avo::BuiltinThemes.all.select { |klass| @themes[klass.id] == klass }
        others = (@themes.values - builtins).sort_by { |klass| klass.title.downcase }
        builtins + others
      end

      def ids = all.map(&:id)

      def find(id)
        return nil if id.blank?

        @themes[id.to_s.to_sym]
      end

      def installed?(id) = find(id).present?

      # The themes the picker offers, in order: `config.appearance[:themes]`
      # when set (unknown ids are dropped, so a stale initializer never raises
      # at render time), every registered theme otherwise.
      def offered
        configured = Avo.configuration.appearance.themes
        return all if configured.blank?

        configured.filter_map { |id| find(id) }
      end

      def offered_ids = offered.map(&:id)

      def offered?(id) = offered_ids.include?(id.to_s.to_sym)

      # The theme a request lands on when nothing valid is picked: the
      # configured default when it is offered, else the first offered theme,
      # else Paper. A `theme:` left out of `themes:` is a misconfiguration the
      # picker cannot show, so it does not win here either.
      def default
        configured = Avo.configuration.appearance.theme
        (configured && offered?(configured) && find(configured)) || offered.first || find(:paper)
      end

      # Stylesheets to link in the layout's theme slot, deduplicated and in
      # picker order. Built-ins are served from one file (`avo/themes`), so they
      # are excluded here and the layout links that file itself.
      def stylesheets
        all.reject(&:builtin?).filter_map(&:stylesheet).uniq
      end

      private

      # `descendants` also returns classes that are no longer the class behind
      # their name: the pre-reload copy in development, or a spec's stubbed
      # constant after the stub is removed. They would derive the same id as
      # the live class and trip the duplicate check, so only a class that is
      # still reachable by its own name (and not anonymous) is a candidate.
      def live?(klass)
        return false if klass.abstract?
        return false if klass.name.blank?

        klass.name.safe_constantize.equal?(klass)
      end

      # Mirrors ResourceManager: the host's `app/avo/themes` is autoloaded under
      # the Avo namespace, so eager loading the namespace surfaces every class
      # before `descendants` is asked.
      def eager_load_local_themes
        return unless defined?(Avo::Themes)

        Rails.autoloaders.main.eager_load_namespace(Avo::Themes)
      rescue Zeitwerk::Error, NameError => e
        Rails.logger&.warn("Avo: could not eager load app/avo/themes (#{e.message})")
      end
    end
  end
end
