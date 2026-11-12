class Avo::Filters::VolunteerSkillsFilter < Avo::Filters::MultipleSelectFilter
  self.name = "Skills"

  def apply(request, query, value)
    query.where("skills && ARRAY[?]::varchar[]", value)
  end

  def options
    Volunteer::SKILLS_OPTIONS.transform_values { |skills| skills.to_h(&:reverse) }
  end
end
