class Avo::ToolsController < Avo::ApplicationController
  def custom_tool
    @page_title = "Custom tool page title"
    breadcrumbs.add "Custom tool"
  end
end
