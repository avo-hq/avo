# frozen_string_literal: true

class Avo::HotkeyComponent < Avo::BaseComponent
  def sections
    @sections ||= [
      build_section(
        "Navigation",
        [
          shortcut(action: "Show keyboard shortcuts", keys: ["?"]),
          shortcut(action: "Focus resource search", keys: {mac: ["Cmd", "K"], other: ["Ctrl", "K"]}),
          shortcut(action: "Toggle sidebar", keys: {mac: ["Cmd", "\\"], other: ["Ctrl", "\\"]}),
          shortcut(action: "Close dialog", keys: ["Esc"]),
          shortcut(
            action: "Navigate options in the confirmation dialog",
            any_of: [["↑"], ["↓"]],
            keys_aria_label: "Up arrow or down arrow"
          ),
          shortcut(action: "Go back", keys: ["B"])
        ]
      ),
      build_section(
        "Records",
        [
          shortcut(action: "Save form", keys: {mac: ["Cmd", "↵"], other: ["Ctrl", "↵"]}),
          shortcut(action: "Create new record (index view)", keys: ["C"]),
          shortcut(action: "Edit record (show view)", keys: ["E"]),
          shortcut(action: "Delete record (show view)", keys: ["D"])
        ]
      )
    ]
  end

  def render_shortcut_keys(shortcut)
    if shortcut[:any_of].present?
      render_shortcut_alternatives(shortcut[:any_of])
    else
      render_chord(shortcut[:keys])
    end
  end

  private

  def build_section(title, shortcuts)
    {
      id: "hotkey-group-#{title.parameterize.underscore}",
      title: title,
      shortcuts: shortcuts
    }
  end

  def shortcut(action:, keys: nil, any_of: nil, keys_aria_label: nil)
    {
      action: action,
      keys: keys,
      any_of: any_of,
      keys_aria_label: keys_aria_label
    }
  end

  def render_shortcut_alternatives(chords)
    helpers.safe_join(
      chords.flat_map.with_index do |chord, index|
        [
          (tag.span("or", class: "hotkey__or", aria: {hidden: true}) if index.positive?),
          render_chord(chord)
        ].compact
      end
    )
  end

  def render_chord(chord)
    tag.span class: "hotkey__combo" do
      helpers.safe_join(chord_fragments(chord))
    end
  end

  def chord_fragments(chord)
    return platform_split_fragments(chord) if platform_split_chord?(chord)

    key_fragments(Array(chord))
  end

  def platform_split_fragments(chord)
    [
      platform_modifier_key,
      *key_fragments(chord[:mac].drop(1), leading_separator: true)
    ]
  end

  def key_fragments(keys, leading_separator: false)
    keys.flat_map.with_index do |key, index|
      [
        (tag.span("+", class: "hotkey__key-separator") if leading_separator || index.positive?),
        tag.kbd(key, class: "hotkey__key")
      ].compact
    end
  end

  def platform_modifier_key
    tag.kbd class: "hotkey__key" do
      helpers.safe_join([
        tag.abbr("⌘", title: "Command", class: "no-underline os-pc:hidden"),
        tag.abbr("CTRL", title: "CTRL", class: "no-underline os-mac:hidden")
      ])
    end
  end

  def platform_split_chord?(chord)
    chord.is_a?(Hash) &&
      chord[:mac].is_a?(Array) &&
      chord[:other].is_a?(Array) &&
      chord[:mac].size == chord[:other].size &&
      chord[:mac].first.to_s == "Cmd" &&
      chord[:other].first.to_s == "Ctrl"
  end
end
