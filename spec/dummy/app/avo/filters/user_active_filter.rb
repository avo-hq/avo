class Avo::Filters::UserActiveFilter < Avo::Filters::SelectFilter
  self.name = "Active"

  def apply(request, query, value)
    query.where(active: ActiveRecord::Type::Boolean.new.cast(value))
  end

  def options
    {"true" => "Active", "false" => "Inactive"}
  end
end
