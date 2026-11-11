class Avo::Resources::Volunteer < Avo::BaseResource
  def fields
    field :id, as: :id
    field :name, as: :text
    field :role, as: :text
    field :event, as: :belongs_to, placeholder: "—"

    field :department, as: :select, grouped_options: Volunteer::DEPARTMENT_OPTIONS
    field :skills, as: :select, multiple: true, grouped_options: Volunteer::SKILLS_OPTIONS
  end

  def filters
    filter Avo::Filters::VolunteerDepartmentFilter
    filter Avo::Filters::VolunteerSkillsFilter
  end
end
