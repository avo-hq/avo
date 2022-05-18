class TeamMembershipResource < Avo::BaseResource
  self.title = :id
  self.includes = [:user, :team]
  self.visible_on_sidebar = false
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  end
  self.hide_from_global_search = true

  field :id, as: :id
  field :id, as: :number, only_on: :edit
  field :level, as: :select, as_description: true, options: ->(**args) { {Beginner: :beginner, Intermediate: :intermediate, Advanced: :advanced, "#{args[:model].id}": "model_id", "#{args[:resource].name}": "resource_name", "#{args[:view]}": "view", "#{args[:field].id}": "field"} }, display_value: true, default: -> { Time.now.hour < 12 ? "advanced" : "beginner" }

  field :user, as: :belongs_to, searchable: false, attach_scope: -> {
    # puts ["parent->", parent, parent.team].inspect
    query.where.not(id: nil)
  }
  field :team, as: :belongs_to
end
