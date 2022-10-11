class MembershipResource < Avo::BaseResource
  self.title = :name
  self.includes = [:user, :team]
  self.visible_on_sidebar = false
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  end
  self.hide_from_global_search = true
  self.model_class = "TeamMembership"

  field :id, as: :id
  field :id, as: :number, only_on: :edit

  field :level,
    as: :select,
    as_description: true,
    display_value: true,
    default: -> { Time.now.hour < 12 ? "advanced" : "beginner" },
    options: ->(model:, resource:, field:, view:) do
      {
        Beginner: :beginner,
        Intermediate: :intermediate,
        Advanced: :advanced,
        "#{model.id}": "model_id",
        "#{resource.name}": "resource_name",
        "#{view}": "view",
        "#{field.id}": "field"
      }
    end

  field :user, as: :belongs_to, searchable: false, attach_scope: -> {
    # puts ["parent->", parent, parent.team].inspect
    query
  }
  field :team, as: :belongs_to
end
