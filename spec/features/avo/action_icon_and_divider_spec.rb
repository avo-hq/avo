require "rails_helper"

RSpec.describe "action icon and divider", type: :feature do
  def icon_path_fragment(icon_filename, take: 20)
    pathname = Avo::Icons::SvgFinder.find_asset("#{icon_filename}.svg").pathname
    svg = File.read(pathname)

    # Grab the first real icon <path> (skip the "stroke='none'" reset path).
    d_values = svg.scan(/\sd="([^"]+)"/).flatten
    d = d_values.find { |value| !value.start_with?("M0 0h24v24H0z") } || d_values.first

    d.to_s[0, take]
  end

  describe "icon and divider" do
    it "Viewing actions with icon and divider" do
      visit "admin/resources/users"

      expect(page).to have_css("button[data-action='click->toggle#togglePanel']")

      world_map_d = icon_path_fragment("tabler/outline/world-map")
      arrow_left_d = icon_path_fragment("tabler/outline/arrow-left")

      click_on "Actions"

      # Assert the rendered icon uses the same SVG paths as our icon pack (avo-icons).
      expect(page).to have_css("path[d*='#{world_map_d}']", visible: false)
      expect(page).to have_css("path[d*='#{arrow_left_d}']", visible: false)

      expect(page).to have_css("[data-component-name='avo/divider_component']", visible: false)
    end
  end
end
