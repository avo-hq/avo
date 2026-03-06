if ::Gem::Version.new(::Pagy::VERSION) < ::Gem::Version.new("43.0")
  require "pagy/extras/trim"
  require "pagy/extras/countless"
  require "pagy/extras/array"
  if ::Gem::Version.new(::Pagy::VERSION) >= ::Gem::Version.new("9.0")
    require "pagy/extras/size"
  end
end

# For locales without native pagy i18n support
def pagy_locale_path(file_name)
  Avo::Engine.root.join("lib", "generators", "avo", "templates", "locales", "pagy", file_name)
end

extra_locales = [
  {locale: "en"},
  {locale: "es"},
  {locale: "fr"},
  {locale: "ja"},
  {locale: "nb"},
  {locale: "pt-BR"},
  {locale: "pt"},
  {locale: "tr"},
  {locale: "nn", filepath: pagy_locale_path("nn.yml")},
  {locale: "ro", filepath: pagy_locale_path("ro.yml")}
]

if defined?(Pagy::I18n)
  if Pagy::I18n.respond_to?(:pathnames) && ::Gem::Version.new(::Pagy::VERSION) >= ::Gem::Version.new("43.0")
    # Load custom dictionaries that are not bundled by Pagy.
    Pagy::I18n.pathnames << Avo::Engine.root.join("lib", "generators", "avo", "templates", "locales", "pagy")
  elsif Pagy::I18n.respond_to?(:build, true)
    Pagy::I18n.send(:build, *extra_locales)
  end
end
