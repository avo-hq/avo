# Pagy 43 has no extras to require, and it loads its own dictionaries (nn and ro included) on first use.
return if Avo::PagyCompat.pagy_43?

require "pagy/extras/trim"
require "pagy/extras/countless"
require "pagy/extras/array"
if ::Pagy::VERSION >= ::Gem::Version.new("9.0")
  require "pagy/extras/size"
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

Pagy::I18n.send(:build, *extra_locales)
