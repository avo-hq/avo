if defined?(Pagy::I18n)
  if Pagy::I18n.respond_to?(:pathnames)
    # Load custom dictionaries that are not bundled by Pagy.
    Pagy::I18n.pathnames << Avo::Engine.root.join("lib", "generators", "avo", "templates", "locales", "pagy")
  end

  icon_translations = {
    "pagy.previous" => File.read(Avo::Icons.root.join("assets", "svgs", "tabler", "outline", "arrow-narrow-left.svg")).gsub(/\s+/, " ").strip,
    "pagy.next" => File.read(Avo::Icons.root.join("assets", "svgs", "tabler", "outline", "arrow-narrow-right.svg")).gsub(/\s+/, " ").strip
  }.freeze

  unless Pagy::I18n.singleton_class.instance_variable_defined?(:@avo_pagy_icon_patch_applied)
    Pagy::I18n.singleton_class.prepend(Module.new do
      define_method :translate do |key, **options|
        icon_translations.fetch(key) { super(key, **options) }
      end
    end)
    Pagy::I18n.singleton_class.instance_variable_set(:@avo_pagy_icon_patch_applied, true)
  end
end
