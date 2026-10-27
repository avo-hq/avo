# frozen_string_literal: true

class Avo::UI::SearchInputComponent < Avo::BaseComponent
  prop :name, default: "q"
  prop :id
  prop :value
  prop :placeholder
  prop :disabled, default: false
  prop :shortcut, default: nil  # :slash or :cmd_k
  prop :classes
  prop :data, default: -> { {} }

  SHORTCUT_HOTKEYS = {slash: "index.focus_search", cmd_k: "advanced_search.open"}.freeze

  def shortcut_hotkey
    Avo::Hotkeys.key_for(SHORTCUT_HOTKEYS[@shortcut]) if @shortcut
  end
end
