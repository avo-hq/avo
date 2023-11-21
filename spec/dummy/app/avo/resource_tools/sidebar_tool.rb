class Avo::ResourceTools::SidebarTool < Avo::BaseResourceTool
  attr_reader :render_panel

  def initialize(**args)
    @render_panel = args[:render_panel]

    super(**args)
  end

  self.name = "Sidebar tool"
  # self.partial = "avo/resource_tools/sidebar_tool"
end
