# frozen_string_literal: true

class Avo::Filters::StartingAt < Avo::Filters::DateTimeFilter
  self.name = "The starting at filter"
  self.button_label = "Filter by start time"
  self.empty_message = "Search by start time"
  self.type = :time
  self.mode = :single

  def apply(request, query, value)
    query.where("to_char(starting_at, 'HH24:MI:SS') = ?", value)
  end
end
