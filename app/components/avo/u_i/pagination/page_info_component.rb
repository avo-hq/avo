# frozen_string_literal: true

class Avo::UI::Pagination::PageInfoComponent < Avo::BaseComponent
  prop :start_item, default: 0
  prop :end_item, default: 0
  prop :total_items, default: 0
end

