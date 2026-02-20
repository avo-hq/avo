# frozen_string_literal: true

class Avo::UI::Pagination::NavigationControlsComponent < Avo::BaseComponent
  prop :current_page, default: 1
  prop :page_numbers, default: [].freeze
  prop :can_go_previous, default: false
  prop :can_go_next, default: false
end

