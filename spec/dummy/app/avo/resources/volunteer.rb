class Avo::Resources::Volunteer < Avo::BaseResource
  def fields
    field :id, as: :id
    field :name, as: :text
    field :role, as: :text
    field :event, as: :belongs_to, foreign_key: :event_uuid, primary_key: :uuid, placeholder: "—"
  end
end
