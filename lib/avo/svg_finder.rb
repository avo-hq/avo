class Avo::SvgFinder
  def self.find_asset(filename)
    new(filename)
  end

  def initialize(filename)
    @filename = filename
  end

  # Use the default static finder logic. If that doesn't find anything, search according to our pattern:
  def pathname
    found_asset = default_strategy

    # Use the found asset
    return found_asset if found_asset.present?

    paths = [
      Rails.root.join("app", "assets", "svgs", @filename).to_s,
      Rails.root.join(@filename).to_s,
      Avo::Engine.root.join("app", "assets", "svgs", @filename).to_s,
      Avo::Engine.root.join("app", "assets", "svgs", "heroicons", "outline", @filename).to_s,
      Avo::Engine.root.join(@filename).to_s,
    ]

    path = paths.find do |path|
      File.exist? path
    end

    path
  end

  def default_strategy
    if ::Rails.application.config.assets.compile
      asset = ::Rails.application.assets[@filename]
      Pathname.new(asset.filename) if asset.present?
    else
      manifest = ::Rails.application.assets_manifest
      asset_path = manifest.assets[@filename]
      unless asset_path.nil?
        ::Rails.root.join(manifest.directory, asset_path)
      end
    end
  end
end

