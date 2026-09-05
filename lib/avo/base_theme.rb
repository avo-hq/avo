module Avo
  # A theme is a named, self-contained look: a stylesheet scoped to
  # `.avo-theme-<id>`, optionally a directory of partial overrides, and
  # optionally brand assets that apply while the theme is active. Subclasses
  # live in the host app (`app/avo/themes/`), in a gem, or in core
  # (`Avo::BuiltinThemes`). See docs/plans/2026-09-03-001-feat-themes-plan.md.
  #
  #   class Avo::Themes::Coastal < Avo::BaseTheme
  #     self.title = "Coastal"
  #     self.description = "Soft sand neutrals, sea-glass accents."
  #     self.scheme = :light
  #   end
  #
  # Every attribute has a default derived from the class name, so the class
  # above is complete: id `:coastal`, stylesheet `avo/themes/coastal`, and a
  # views directory at `app/views/avo/themes/coastal` when it exists.
  #
  # A theme owns its whole look by default: it is drawn for one color scheme
  # (`scheme`, light unless said otherwise) and the neutral, accent, and
  # scheme pickers are hidden while it is active (`lock`). A theme that wants
  # to be a base for the user's own picks, the way Paper is, unlocks them and
  # then has to style both schemes, because the user can switch.
  #
  # Attributes are plain class-level ivars looked up through the superclass
  # chain rather than `class_attribute`, because the derived defaults need to
  # run per subclass and `class_attribute`'s writer redefines the reader.
  class BaseTheme
    # Keys of `config.appearance` a theme may override while active. Everything
    # else on the appearance hash is policy (scheme, locks, persistence, the
    # theme list) or palette (neutral/accent), and neither belongs to a theme:
    # colors go in the stylesheet, policy stays with the host.
    # Guarded like Avo::Configuration::Appearance: Zeitwerk and the gem's own
    # require chain can both load this file, and a re-assigned frozen constant
    # warns.
    unless defined?(APPEARANCE_KEYS)
      APPEARANCE_KEYS = %i[logo logo_dark logomark logomark_dark favicon favicon_dark placeholder chart_colors].freeze
      LOCKABLE = %i[neutral accent scheme].freeze
      SCHEMES = %i[light dark].freeze
      ID_FORMAT = /\A[a-z][a-z0-9_]*\z/
    end

    class << self
      attr_writer :title, :description, :attribution

      def id=(value)
        value = value.to_s
        raise ArgumentError, "#{name}.id must match #{ID_FORMAT.inspect}, got #{value.inspect}" unless ID_FORMAT.match?(value)

        @id = value.to_sym
      end

      def id
        inherited_ivar(:@id) || derived_id
      end

      def title
        inherited_ivar(:@title).presence || id.to_s.titleize
      end

      def description = inherited_ivar(:@description)

      # Free-text credit for a palette reused under its license. Rendered
      # nowhere in the UI; listed in NOTICE for the built-ins.
      def attribution = inherited_ivar(:@attribution)

      # Asset-pipeline path of the theme's stylesheet. `nil` means the theme
      # ships no stylesheet of its own (Paper: the defaults are the theme).
      def stylesheet
        return inherited_ivar(:@stylesheet) if inherited_set?(:@stylesheet)

        "avo/themes/#{id}"
      end

      def stylesheet=(value)
        @stylesheet = value.presence
      end

      # Directory prepended to the view path while the theme is active, or nil.
      # Derived from the app or engine root so a local theme and a gem theme
      # both find their partials without configuration.
      def views
        return inherited_ivar(:@views) if inherited_set?(:@views)

        path = root.join("app", "views", "avo", "themes", id.to_s)
        path.directory? ? path : nil
      end

      def views=(value)
        @views = value.present? ? Pathname.new(value.to_s) : nil
      end

      # The color scheme the theme is drawn for. It is forced on <html> while
      # the theme locks `:scheme` (the default), so a dark theme is dark on a
      # light OS and its stylesheet needs one block, not two.
      def scheme = inherited_ivar(:@scheme) || :light

      def scheme=(value)
        value = value.to_s.to_sym
        raise ArgumentError, "#{name}.scheme accepts #{SCHEMES.inspect}, got #{value.inspect}" unless SCHEMES.include?(value)

        @scheme = value
      end

      def dark? = scheme == :dark

      # The pickers hidden while the theme is active. Everything by default:
      # a theme is a finished look, and the neutral, accent, and scheme picks
      # are what Paper offers instead of a look. Unlock a dimension and the
      # user's pick applies on top of the theme's stylesheet.
      def lock
        return inherited_ivar(:@lock) if inherited_set?(:@lock)

        LOCKABLE
      end

      def lock=(value)
        value = Array(value).map(&:to_sym)
        unknown = value - LOCKABLE
        raise ArgumentError, "#{name}.lock accepts #{LOCKABLE.inspect}, got #{unknown.inspect}" if unknown.any?

        @lock = value.freeze
      end

      def forces_scheme? = locks?(:scheme)

      def appearance = inherited_ivar(:@appearance) || {}

      def appearance=(value)
        value = (value || {}).to_h.symbolize_keys
        unknown = value.keys - APPEARANCE_KEYS
        if unknown.any?
          raise ArgumentError, "#{name}.appearance accepts #{APPEARANCE_KEYS.inspect}; got #{unknown.inspect}. " \
            "Colors belong in the theme's stylesheet, and scheme/lock/persistence/themes stay with the host app."
        end

        @appearance = value.freeze
      end

      def has_views? = views.present?

      # A switch to or from this theme needs a full page render, not a class swap.
      def needs_visit? = has_views? || appearance.present?

      def css_class = "avo-theme-#{id}"

      def locks?(dimension) = lock.include?(dimension.to_sym)

      # The root the views directory is derived from: the engine root for a gem
      # theme (the class lives under an engine namespace), the app root
      # otherwise. Built-ins ship no views.
      def root
        engine = module_parent_engine
        engine ? engine.root : Rails.root
      end

      def builtin? = false

      # An abstract theme is a shared parent (Avo::BuiltinThemes::Base) and is
      # never registered. Not inherited: a subclass of an abstract theme is a
      # theme.
      def abstract!
        @abstract = true
      end

      def abstract? = instance_variable_defined?(:@abstract) && @abstract == true

      def to_s = id.to_s

      def inspect = "#<#{name} id=#{id.inspect}>"

      private

      # Walk up to (but not including) BaseTheme for the first class that set
      # the ivar, so a theme subclassing another theme inherits its settings.
      def inherited_ivar(ivar)
        klass = self
        while klass && klass != BaseTheme
          return klass.instance_variable_get(ivar) if klass.instance_variable_defined?(ivar)

          klass = klass.superclass
        end
        nil
      end

      def inherited_set?(ivar)
        klass = self
        while klass && klass != BaseTheme
          return true if klass.instance_variable_defined?(ivar)

          klass = klass.superclass
        end
        false
      end

      # `Avo::CoastalTheme::Theme` -> `Avo::CoastalTheme::Engine` when that gem
      # ships one; nil for `Avo::Themes::Coastal` in the host app.
      def module_parent_engine
        parent = module_parent
        return nil if parent == Object || parent == Avo
        return nil if defined?(Avo::Themes) && parent == Avo::Themes

        engine = "#{parent.name}::Engine".safe_constantize
        engine if engine.is_a?(Class) && engine < Rails::Engine
      end

      def derived_id
        segment = name.to_s.demodulize
        segment = module_parent.name.to_s.demodulize.delete_suffix("Theme") if segment == "Theme"
        id = segment.underscore
        raise ArgumentError, "Cannot derive a theme id from #{name}; set `self.id`." unless ID_FORMAT.match?(id)

        id.to_sym
      end
    end
  end
end
