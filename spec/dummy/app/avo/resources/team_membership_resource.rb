class TeamMembershipResource < Avo::BaseResource
  self.title = :id
  self.search = :id
  self.includes = [:user, :team]

  field :id, as: :id
  field :level, as: :select, options: {'Beginner': :beginner, 'Intermediate': :intermediate, 'Advanced': :advanced}, display_value: true, default: -> { Time.now.hour < 12 ? "advanced" : "beginner" }
  field :user, as: :belongs_to
  field :team, as: :belongs_to
end
