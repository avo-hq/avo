# frozen_string_literal: true

class Avo::Filters::Birthday < Avo::Filters::DateTimeFilter
  self.name = "Birthday"
  self.button_label = "Apply birthday filter"
  self.type = :date
  # self.mode = :range
  # self.visible = -> do
  #   true
  # end

  def apply(request, query, value)
    start_date, end_date = value.split(" to ")

    query.where(Hash[:birthday, start_date..end_date])
  end

  # def format
  #   case type
  #   when :date_time
  #     'yyyy-LL-dd TT'
  #   when :date
  #     'yyyy-LL-dd'
  #   end
  # end

  # def picker_format
  #   case type
  #   when :date_time
  #     'Y-m-d H:i:S'
  #   when :time
  #     'Y-m-d'
  #   end
  # end
end
