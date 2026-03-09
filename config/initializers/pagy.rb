if defined?(Pagy::I18n)
  if Pagy::I18n.respond_to?(:pathnames)
    # Load custom dictionaries that are not bundled by Pagy.
    Pagy::I18n.pathnames << Avo::Engine.root.join("lib", "generators", "avo", "templates", "locales", "pagy")
  end
end

arrow_left_svg = File.read(Avo::Icons.root.join("assets", "svgs", "tabler", "outline", "arrow-narrow-left.svg")).gsub(/\s+/, " ").strip
arrow_right_svg = File.read(Avo::Icons.root.join("assets", "svgs", "tabler", "outline", "arrow-narrow-right.svg")).gsub(/\s+/, " ").strip

Pagy::I18n::DATA.each_value do |(data, _)|
  data["pagy.prev"] = arrow_left_svg
  data["pagy.next"] = arrow_right_svg
end
