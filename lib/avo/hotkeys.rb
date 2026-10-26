module Avo
  # Registry of every rebindable keyboard shortcut. Keys use the @github/hotkey string format, and
  # the developer overrides them by ID in `config.hotkeys[:bindings]`.
  module Hotkeys
    Entry = Data.define(:id, :default, :label, :section, :scopes)

    # Escape and Mod+Enter close and submit every modal and form. They stay fixed so no override can
    # leave a dialog without a keyboard way out, which is why they are not entries here.
    LOCKED_KEYS = ["Escape", "Mod+Enter"].freeze

    # Mod sorts with Control and Meta so "Mod+Shift+k" and "Shift+Mod+k" compare equal.
    MODIFIER_ORDER = %w[Control Mod Alt Meta Shift].freeze

    class << self
      def core_entries
        @core_entries ||= [
          entry("shortcuts.toggle", "Shift+?", "Show keyboard shortcuts"),
          entry("navigation.focus_content", "Shift+T", "Focus page content"),
          entry("sidebar.toggle", "Shift+|", "Toggle sidebar"),
          entry("navigation.go_back", "b", "Go back"),
          entry("navigation.reload", "r r r", "Reload the page"),
          entry("hotkeys.toggle_badges", "Shift+K", "Toggle keyboard shortcut badges"),
          entry("record.edit", "e", "Edit record", scopes: [:show, :index]),
          entry("record.delete", "d", "Delete record", scopes: [:show, :index]),
          entry("resource.actions", "a", "Open actions", scopes: [:show, :edit, :index]),
          entry("resource.new", "c", "Create new record", scopes: [:show, :index]),
          entry("resource.go_to_index", "i", "Go to index", scopes: [:show, :edit]),
          entry("appearance.cycle_scheme", "Shift+M", "Cycle color scheme (auto / light / dark)"),
          entry("appearance.cycle_neutral", "Shift+N", "Cycle neutral theme"),
          entry("appearance.cycle_accent", "Shift+A", "Cycle accent color"),
          entry("appearance.toggle_sound", "Shift+S", "Toggle appearance sound"),
          entry("index.focus_search", "/", "Focus search", scopes: [:index]),
          entry("index.next_row", "j", "Focus table and move to next row", scopes: [:index]),
          entry("index.previous_row", "k", "Focus table and move to previous row", scopes: [:index]),
          entry("index.view_table", "v t", "Table view", scopes: [:index]),
          entry("index.view_grid", "v g", "Grid view", scopes: [:index]),
          entry("index.view_map", "v m", "Map view", scopes: [:index])
        ].freeze
      end

      def core_namespaces
        core_entries.map { |entry| namespace_of(entry.id) }.uniq
      end

      def entries
        core_entries + Avo.plugin_manager.plugins.flat_map(&:hotkeys)
      end

      def find(id)
        entries.find { |entry| entry.id == id.to_s }
      end

      # The key bound to `id`, or nil when the developer disabled it.
      def key_for(id)
        bindings[id.to_s]
      end

      def bindings
        overrides = Avo.configuration.hotkeys[:bindings].to_h.transform_keys(&:to_s)

        entries.to_h do |entry|
          key = overrides.fetch(entry.id, entry.default)
          [entry.id, key.presence]
        end
      end

      def entry(id, default, label, section: nil, scopes: [:global])
        Entry.new(id:, default:, label:, section:, scopes:)
      end

      def validate!
        known_namespaces = entries.map { |entry| namespace_of(entry.id) }.uniq

        Avo.configuration.hotkeys[:bindings].to_h.each do |id, key|
          next unless known_namespaces.include?(namespace_of(id))

          raise ArgumentError, "Unknown hotkey \"#{id}\" in config.hotkeys[:bindings]." if find(id).nil?
          unless key == false || key.nil? || key.is_a?(String)
            raise ArgumentError, "Hotkey \"#{id}\" must be a String in @github/hotkey format, or false to disable it."
          end
        end

        validate_conflicts!
      end

      # Splits a hotkey string into aliases, each an array of chords, following @github/hotkey's own
      # parser: a comma right after a key separates aliases, so "Control+,,x" is Control+, or x.
      def parse(hotkey)
        aliases = []
        sequence = [+""]
        comma_is_separator = false

        hotkey.to_s.each_char do |char|
          if comma_is_separator && char == ","
            aliases << sequence
            sequence = [+""]
            comma_is_separator = false
          elsif char == " "
            sequence << +""
            comma_is_separator = false
          else
            comma_is_separator = char != "+"
            sequence.last << char
          end
        end
        aliases << sequence

        aliases.map { |chords| chords.reject(&:empty?).map { |chord| sort_modifiers(chord) } }.reject(&:empty?)
      end

      private

      def namespace_of(id)
        id.to_s.split(".").first
      end

      def sort_modifiers(chord)
        parts = chord.split("+")
        parts.sort_by.with_index { |part, index| [MODIFIER_ORDER.index(part) || MODIFIER_ORDER.size, index] }.join("+")
      end

      def validate_conflicts!
        bound = bindings.filter_map { |id, key| [find(id), parse(key)] if key }
        locked = LOCKED_KEYS.flat_map { |key| parse(key) }

        bound.each do |entry, sequences|
          sequences.each do |sequence|
            if locked.include?(sequence)
              raise ArgumentError, "Hotkey \"#{entry.id}\" can't use #{sequence.join(" ")}: that key is reserved."
            end
          end
        end

        bound.combination(2).each do |(entry, sequences), (other, other_sequences)|
          next unless overlapping_scopes?(entry, other)

          sequences.product(other_sequences).each do |sequence, other_sequence|
            short, long = [sequence, other_sequence].sort_by(&:length)
            next unless long.first(short.length) == short

            reason = (short == long) ? "both use" : "#{short.join(" ")} blocks the sequence"
            raise ArgumentError,
              "Hotkeys \"#{entry.id}\" and \"#{other.id}\" conflict: #{reason} #{long.join(" ")}."
          end
        end
      end

      def overlapping_scopes?(entry, other)
        entry.scopes.include?(:global) || other.scopes.include?(:global) || entry.scopes.intersect?(other.scopes)
      end
    end
  end
end
