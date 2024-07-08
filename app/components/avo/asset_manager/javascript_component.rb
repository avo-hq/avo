# frozen_string_literal: true

class Avo::AssetManager::JavascriptComponent < Avo::BaseComponent
  prop :asset_manager, Avo::AssetManager

  delegate :javascripts, to: :@asset_manager
end
