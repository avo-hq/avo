class Avo::Filters::VolunteerDepartmentFilter < Avo::Filters::SelectFilter
  self.name = "Department"

  def apply(request, query, value)
    query.where(department: value)
  end

  def options
    {
      "Administration" => {hr: "HR", Finance: "Finance", legal: "Legal"},
      "Operations" => {events: "Events", logistics: "Logistics", facilities: "Facilities"},
      "Technology" => {development: "Development", support: "Support", infrastructure: "Infrastructure"}
    }
  end
end
