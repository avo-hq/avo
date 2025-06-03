class Avo::Resources::Galaxy::Sector::Planet < Avo::BaseResource
  def fields
    field :id, as: :id
    field :name, as: :text

    field :satellites, as: :has_many
  end
end
