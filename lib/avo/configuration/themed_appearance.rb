# The appearance a request renders with: the configured Avo::Configuration::Appearance
# with the active theme's brand assets laid over it. Only the keys a theme may set
# (Avo::BaseTheme::APPEARANCE_KEYS) are overridable; every other reader falls
# through to the configured appearance unchanged.
class Avo::Configuration::ThemedAppearance
  attr_reader :base, :overrides

  def initialize(base, overrides = {})
    @base = base
    @overrides = (overrides || {}).symbolize_keys.slice(*Avo::BaseTheme::APPEARANCE_KEYS)
  end

  Avo::BaseTheme::APPEARANCE_KEYS.each do |key|
    define_method(key) do
      @overrides.key?(key) ? @overrides[key] : @base.public_send(key)
    end
  end

  def method_missing(name, ...)
    @base.respond_to?(name) ? @base.public_send(name, ...) : super
  end

  def respond_to_missing?(name, include_private = false)
    @base.respond_to?(name, include_private) || super
  end
end
