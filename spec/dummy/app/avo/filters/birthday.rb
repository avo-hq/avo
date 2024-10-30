# frozen_string_literal: true

class Avo::Filters::Birthday < Avo::Filters::DateTimeFilter
  self.name = "Birthday"
  self.button_label = "Apply birthday filter"
  self.empty_message = "Filter by birthday"
  self.type = :date

  def apply(request, query, value)
    start_date, end_date = value.split(" to ")

    query.where(birthday: start_date..end_date)
  end
end
