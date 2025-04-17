class Avo::Resources::Volunteer < Avo::BaseResource
  def fields
    field :id, as: :id
    field :name, as: :text
    field :role, as: :text
    field :event, as: :belongs_to, placeholder: "—"
  end
end
