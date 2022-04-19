class MembersFilter < Avo::Filters::BooleanFilter
  self.name = "Members filter"

  def apply(request, query, value)
    return query.where(id: Team.joins(:memberships).group("teams.id").count.keys) if value['has_members']

    query
  end

  def options
    {
      'has_members': "Has Members"
    }
  end

  def default
    {
      has_members: true
    }
  end
end
