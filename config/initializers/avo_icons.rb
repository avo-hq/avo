# Configure avo-icons to include Avo's SVG paths
Avo::Icons.configure do |config|
  config.add_path(Avo::Engine.root.join("app", "assets", "svgs"))
  config.add_path(Avo::Engine.root.join("app", "assets", "svgs", "avo"))
end

