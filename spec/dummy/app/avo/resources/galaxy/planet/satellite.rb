class Avo::Resources::Galaxy::Planet::Satellite < Avo::BaseResource
  self.title = :name

  def fields
    field :id, as: :id
    field :name, as: :text
    field :planet, as: :belongs_to
  end
end
