class Avo::Resources::Attendee < Avo::Resources::ArrayResource
  def fields
    field :id, as: :id
    field :name
    field :role
    field :organization
  end
end


