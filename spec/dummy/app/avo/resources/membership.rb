class Avo::Resources::Membership < Avo::BaseResource
  self.includes = [:user, :team]
  self.visible_on_sidebar = false
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  }
  self.model_class = "TeamMembership"
  self.stimulus_controllers = "test"

  def fields
    field :id, as: :id
    field :id, as: :number, only_on: :edit

    field :level,
      as: :select,
      display_value: true,
      default: -> { Time.now.hour < 12 ? "advanced" : "beginner" },
      grouped_options: -> do
        {
          Skills: {
            Beginner: :beginner,
            Intermediate: :intermediate,
            Advanced: :advanced,
          },
          Meta: {
            "Record ID (#{record.id})": record.id,
            "Resource Name (#{resource.name})": resource.name,
            "View (#{view})": view,
            "Field ID (#{field.id})": field.id
          }
        }
      end

    field :user, as: :belongs_to, searchable: false, attach_scope: -> {
      # puts ["parent->", parent, parent.team].inspect
      query
    }
    field :team, as: :belongs_to
  end

  # tool Avo::ResourceTools::TeamMembershipToolPlayground, show_on: :all
end
