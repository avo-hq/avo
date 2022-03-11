class Avo::ToolsController < Avo::ApplicationController
  def dashboard
    flash.now[:notice] = "This is a very long notice notiifcation to dusplay on mobile"
    flash.now[:error] = "This is a very long error notiifcation to dusplay on mobile"
    @page_title = "Dashboard"
  end
end
