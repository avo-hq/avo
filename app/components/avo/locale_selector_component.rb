# frozen_string_literal: true

# The language picker in the top navbar, beside the appearance switcher. Each
# option submits to Avo::LocalesController, which stores the choice in a
# per-viewer cookie.
class Avo::LocaleSelectorComponent < Avo::BaseComponent
  # Defaults to Avo.configuration.locale_selector_locales.
  prop :locales do |value|
    value&.map(&:to_s)
  end

  def render?
    locales.size >= 2
  end

  def locales
    @locales || Avo.configuration.locale_selector_locales
  end

  def current?(locale)
    locale == I18n.locale.to_s
  end

  def current_name
    Avo::Locales.name_for(I18n.locale)
  end

  def name_for(locale)
    Avo::Locales.name_for(locale)
  end

  # Long lists get the dropdown's type-to-filter input.
  def searchable?
    locales.size > 8
  end

  # The short tag shown on the trigger and beside each name: "EN", "PT-BR".
  def code_for(locale)
    locale.to_s.upcase
  end

  def item_classes(locale)
    class_names("locale-selector__item", "dropdown-menu__item--active": current?(locale))
  end
end
