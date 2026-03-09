if defined?(Pagy::I18n)
  if Pagy::I18n.respond_to?(:pathnames)
    # Load custom dictionaries that are not bundled by Pagy.
    Pagy::I18n.pathnames << Avo::Engine.root.join("lib", "generators", "avo", "templates", "locales", "pagy")
  end
end
