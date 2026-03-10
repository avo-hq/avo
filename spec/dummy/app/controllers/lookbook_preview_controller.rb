class LookbookPreviewController < Lookbook::PreviewController
  include Avo::UrlHelpers
  helper Avo::ApplicationHelper

  helper_method :avo, :resources_path, :related_resources_path

  def avo
    Avo::Engine.routes.url_helpers
  end
end
