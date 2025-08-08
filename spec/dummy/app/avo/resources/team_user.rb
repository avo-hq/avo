class Avo::Resources::TeamUser < Avo::BaseResource
  self.model_class = "User"

  def fields
    field :id, as: :id
  end
end
