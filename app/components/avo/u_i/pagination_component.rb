# frozen_string_literal: true

class Avo::UI::PaginationComponent < Avo::BaseComponent
  prop :current_page, default: 1
  prop :total_items, default: 0
  prop :items_per_page, default: 24
  prop :visible_pages, default: 3
  prop :per_page_options, default: [12, 24, 48, 96].freeze
  prop :on_page_change, default: nil
  prop :on_per_page_change, default: nil

  def total_pages
    return 1 if @total_items.zero?

    (@total_items.to_f / @items_per_page).ceil
  end

  def start_item
    return 0 if @total_items.zero?

    ((@current_page - 1) * @items_per_page) + 1
  end

  def end_item
    [start_item + @items_per_page - 1, @total_items].min
  end

  def page_numbers
    pages = []
    start_page = [@current_page - (@visible_pages / 2), 1].max
    end_page = [start_page + @visible_pages - 1, total_pages].min

    # Adjust start_page if we're near the end
    if end_page - start_page < @visible_pages - 1
      start_page = [end_page - @visible_pages + 1, 1].max
    end

    (start_page..end_page).each do |page|
      pages << page
    end

    pages
  end

  def can_go_previous?
    @current_page > 1
  end

  def can_go_next?
    @current_page < total_pages
  end

  def per_page_display_text
    content_tag(:span, @items_per_page, class: "font-bold") + " per page"
  end
end

