# frozen_string_literal: true

class Avo::AssetManager::StylesheetComponent < Avo::BaseComponent
  attr_reader :asset_manager

  def initialize(asset_manager:)
    @asset_manager = asset_manager
  end

  def stylesheets
    asset_manager.stylesheets
  end
end
