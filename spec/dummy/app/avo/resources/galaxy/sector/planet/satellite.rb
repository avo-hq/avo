class Avo::Resources::Galaxy::Sector::Planet::Satellite < Avo::BaseResource
  def fields
    field :id, as: :id
    field :name, as: :text
    field :planet, as: :belongs_to
  end
end
