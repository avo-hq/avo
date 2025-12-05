# Pagination Component Preview
#
# This preview demonstrates the Avo::UI::PaginationComponent
#
# To view in Lookbook:
# 1. Start the development server: `bin/dev`
# 2. Visit: http://localhost:3030/avo/lookbook
# 3. Navigate to: UI::PaginationComponentPreview
#
# The component matches the Figma design at:
# https://www.figma.com/design/Enmp0p0u8wFG0SuysUDszX/Avo-Design-System?node-id=1541-30336

class UI::PaginationComponentPreview < Lookbook::Preview
  include Avo::ApplicationHelper
  include ::ApplicationHelper

  # Default pagination state
  # @param current_page number
  # @param total_items number
  # @param items_per_page number
  def default(current_page: 1, total_items: 1426, items_per_page: 24)
    render Avo::UI::PaginationComponent.new(
      current_page: current_page,
      total_items: total_items,
      items_per_page: items_per_page
    )
  end

  # First page
  def first_page
    render Avo::UI::PaginationComponent.new(
      current_page: 1,
      total_items: 1426,
      items_per_page: 24
    )
  end

  # Middle page
  def middle_page
    render Avo::UI::PaginationComponent.new(
      current_page: 15,
      total_items: 1426,
      items_per_page: 24
    )
  end

  # Last page
  def last_page
    render Avo::UI::PaginationComponent.new(
      current_page: 60,
      total_items: 1426,
      items_per_page: 24
    )
  end

  # Few items
  def few_items
    render Avo::UI::PaginationComponent.new(
      current_page: 1,
      total_items: 48,
      items_per_page: 24
    )
  end

  # Single page
  def single_page
    render Avo::UI::PaginationComponent.new(
      current_page: 1,
      total_items: 10,
      items_per_page: 24
    )
  end

  # Different per page options
  def custom_per_page_options
    render Avo::UI::PaginationComponent.new(
      current_page: 1,
      total_items: 1426,
      items_per_page: 48,
      per_page_options: [12, 24, 48, 96, 192]
    )
  end

  # More visible pages
  def more_visible_pages
    render Avo::UI::PaginationComponent.new(
      current_page: 5,
      total_items: 1426,
      items_per_page: 24,
      visible_pages: 5
    )
  end
end

