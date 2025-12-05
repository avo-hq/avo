# frozen_string_literal: true

class Avo::UI::Pagination::PerPageSelectorComponent < Avo::BaseComponent
  prop :items_per_page, default: 24
  prop :per_page_options, default: [12, 24, 48, 96].freeze
end

