# frozen_string_literal: true

class Avo::AssetManager::JavascriptComponent < ViewComponent::Base
  attr_reader :asset_manager

  def initialize(asset_manager:)
    @asset_manager = asset_manager
  end

  def javascripts
    asset_manager.javascripts
  end
end
