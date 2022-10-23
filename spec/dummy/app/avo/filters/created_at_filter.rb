class CreatedAtFilter < Avo::Filters::DateTimeFilter
  self.date_field = :created_at
end
