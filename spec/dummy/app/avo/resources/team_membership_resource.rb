class TeamMembershipResource < BaseResource
  self.title = :id
  self.search = :id
  self.includes = [:user, :team]

  def fields
    f.id
    f.select :level, options: { 'Beginner': :beginner, 'Intermediate': :intermediate, 'Advanced': :advanced }, display_value: true, default: -> (model, resource, view, field) { Time.now.hour < 12 ? 'advanced' : 'beginner' }
    f.belongs_to :user
    f.belongs_to :team
  end
end

