class Avo::Resources::Galaxy::Planet < Avo::BaseResource
  self.title = :name

  def fields
    field :id, as: :id
    field :name, as: :text
    field :satellites, as: :has_many
  end
end
