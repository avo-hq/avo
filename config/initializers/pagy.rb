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

# Override prev/next labels for all locales with tabler/outline/arrow-up.
# Prev = rotated -90deg (pointing left), Next = rotated 90deg (pointing right).
arrow_up_path = Avo::Icons.root.join("assets", "svgs", "tabler", "outline", "arrow-up.svg")
arrow_up_svg = File.read(arrow_up_path).gsub(/\s+/, " ").strip

PAGY_ARROW_SVG = arrow_up_svg.freeze

Pagy::I18n::DATA.each_value do |(data, _)|
  data["pagy.prev"] = PAGY_ARROW_SVG
  data["pagy.next"] = PAGY_ARROW_SVG
end
