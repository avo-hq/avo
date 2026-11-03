# frozen_string_literal: true

class Avo::KeyboardShortcutsComponent < Avo::BaseComponent
  KEY_LABELS = {
    "enter" => "↵",
    "return" => "↵",
    "escape" => "Esc",
    "arrowup" => "↑",
    "arrowdown" => "↓",
    "arrowleft" => "←",
    "arrowright" => "→",
    "plus" => "+"
  }.freeze

  def sections
    @sections ||= [
      build_section(
        "Navigation",
        [
          bound("shortcuts.toggle"),
          bound("navigation.focus_content"),
          bound("sidebar.toggle"),
          fixed("Close modal", "Escape"),
          fixed("Navigate options in the modal", "ArrowUp,ArrowDown", keys_aria_label: "Up arrow or down arrow"),
          bound("navigation.go_back"),
          bound("navigation.reload"),
          bound("hotkeys.toggle_badges")
        ]
      ),
      build_section(
        "Edit view",
        [
          fixed("Submit form", "Mod+Enter"),
          fixed("Unfocus field", "Escape"),
          bound("resource.go_to_index")
        ]
      ),
      build_section(
        "Show view",
        [
          bound("record.delete"),
          bound("record.edit"),
          bound("resource.actions"),
          bound("resource.new"),
          bound("resource.go_to_index")
        ]
      ),
      build_section(
        "Action",
        [
          fixed("Run action", "Mod+Enter"),
          fixed("Cancel action", "Escape")
        ]
      ),
      build_section(
        "Appearance",
        [
          bound("appearance.cycle_scheme"),
          bound("appearance.cycle_neutral"),
          bound("appearance.cycle_accent"),
          bound("appearance.toggle_sound")
        ]
      ),
      build_section(
        "Index view",
        [
          bound("index.focus_search"),
          bound("resource.new"),
          bound("resource.actions"),
          bound("index.next_row"),
          bound("index.previous_row"),
          fixed("Navigate rows (when table is focused)", "ArrowUp,ArrowDown", keys_aria_label: "Up arrow or down arrow"),
          fixed("Open record", "Enter"),
          fixed("Select / deselect row", "Space"),
          fixed("Clear row focus / deselect rows", "Escape"),
          bound("index.view_table"),
          bound("index.view_grid"),
          bound("index.view_map")
        ]
      )
    ].then { |core_sections| with_plugin_shortcuts(core_sections) }
      .reject { |section| section[:shortcuts].empty? }
  end

  def render_shortcut_keys(shortcut)
    aliases = Avo::Hotkeys.parse(shortcut[:hotkey])

    helpers.safe_join(
      aliases.flat_map.with_index do |sequence, index|
        [
          (tag.span("or", class: "hotkey__or", aria: {hidden: true}) if index.positive?),
          *sequence.map { |chord| render_chord(chord) }
        ].compact
      end
    )
  end

  private

  # Plugins name the section their shortcuts belong to; a section core doesn't have is added at the end.
  def with_plugin_shortcuts(core_sections)
    plugin_entries = Avo::Hotkeys.entries - Avo::Hotkeys.core_entries

    plugin_entries.group_by { |entry| entry.section.presence || "Other" }.each do |title, entries|
      section = core_sections.find { |core_section| core_section[:title] == title }
      section ||= build_section(title, []).tap { |new_section| core_sections << new_section }
      section[:shortcuts].concat(entries.filter_map { |entry| bound(entry.id) })
    end

    core_sections
  end

  def build_section(title, shortcuts)
    {
      id: "hotkey-group-#{title.parameterize.underscore}",
      title: title,
      shortcuts: shortcuts.compact
    }
  end

  # A disabled binding returns nil so the row disappears from the modal.
  def bound(id)
    hotkey = Avo::Hotkeys.key_for(id)
    return if hotkey.nil?

    # An alias binding ("j,ArrowDown") shows its first alternative here, as the badges do.
    {action: Avo::Hotkeys.find(id).label, hotkey: Avo::Hotkeys.parse(hotkey).first.join(" "), keys_aria_label: nil}
  end

  def fixed(action, hotkey, keys_aria_label: nil)
    {action:, hotkey:, keys_aria_label:}
  end

  def render_chord(chord)
    tag.span class: "hotkey__combo" do
      helpers.safe_join(
        chord.split("+").flat_map.with_index do |key, index|
          [
            (tag.span("+", class: "hotkey__key-separator") if index.positive?),
            render_key(key)
          ].compact
        end
      )
    end
  end

  def render_key(key)
    return platform_modifier_key if key == "Mod"
    return tag.kbd("Ctrl") if key == "Control"
    return tag.kbd("⌘") if key == "Meta"

    tag.kbd(KEY_LABELS.fetch(key.downcase, (key.length == 1) ? key.upcase : key))
  end

  def platform_modifier_key
    tag.kbd do
      helpers.safe_join([
        tag.abbr("⌘", title: "Command", class: "no-underline os-pc:hidden"),
        tag.abbr("CTRL", title: "CTRL", class: "no-underline os-mac:hidden")
      ])
    end
  end
end
