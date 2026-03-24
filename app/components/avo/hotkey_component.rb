# frozen_string_literal: true

class Avo::HotkeyComponent < Avo::BaseComponent
  def sections
    @sections ||= [
      build_section(
        :navigation,
        [
          shortcut(action_key: :"hotkey.navigation.show", default_action: "Show keyboard shortcuts", keys: ["?"]),
          shortcut(action_key: :"hotkey.navigation.search", default_action: "Focus resource search", keys: {mac: ["Cmd", "K"], other: ["Ctrl", "K"]}),
          shortcut(action_key: :"hotkey.navigation.sidebar", default_action: "Toggle sidebar", keys: {mac: ["Cmd", "\\"], other: ["Ctrl", "\\"]}),
          shortcut(action_key: :"hotkey.navigation.close", default_action: "Close dialog", keys: ["Esc"]),
          shortcut(
            action_key: :"hotkey.navigation.confirm_dialog",
            default_action: "Navigate options in the confirmation dialog",
            any_of: [["↑"], ["↓"]],
            keys_aria_label_key: :"hotkey.navigation.confirm_dialog_keys",
            default_keys_aria_label: "Up arrow or down arrow"
          ),
          shortcut(action_key: :"hotkey.navigation.back", default_action: "Go back", keys: ["B"])
        ]
      ),
      build_section(
        :records,
        [
          shortcut(action_key: :"hotkey.records.save", default_action: "Save form", keys: {mac: ["Cmd", "↵"], other: ["Ctrl", "↵"]}),
          shortcut(action_key: :"hotkey.records.create", default_action: "Create new record (index view)", keys: ["C"]),
          shortcut(action_key: :"hotkey.records.edit", default_action: "Edit record (show view)", keys: ["E"]),
          shortcut(action_key: :"hotkey.records.delete", default_action: "Delete record (show view)", keys: ["D"])
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

  def build_section(section_name, shortcuts)
    title = t("avo.hotkey.sections.#{section_name}", default: section_name.to_s.humanize)

    {
      id: "hotkey-group-#{section_name}",
      title: title,
      shortcuts: shortcuts
    }
  end

  def shortcut(action_key:, default_action:, keys: nil, any_of: nil, keys_aria_label_key: nil, default_keys_aria_label: nil)
    {
      action: t("avo.#{action_key}", default: default_action),
      keys: keys,
      any_of: any_of,
      keys_aria_label: keys_aria_label_key.present? ? t("avo.#{keys_aria_label_key}", default: default_keys_aria_label) : nil
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
