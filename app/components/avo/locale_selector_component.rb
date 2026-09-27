# frozen_string_literal: true

# The "Language" entry in the profile menu. Each option submits to
# Avo::LocalesController, which stores the choice in a per-viewer cookie.
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

  def panel_id
    @panel_id ||= "locale-selector-#{SecureRandom.hex(3)}"
  end

  def item_classes(locale)
    class_names("locale-selector__item", "locale-selector__item--current": current?(locale))
  end
end
