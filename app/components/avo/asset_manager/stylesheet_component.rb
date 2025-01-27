# frozen_string_literal: true

class Avo::AssetManager::StylesheetComponent < Avo::BaseComponent
  prop :asset_manager

  delegate :stylesheets, to: :@asset_manager
end
