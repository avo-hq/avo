class Avo::Resources::Update < Avo::BaseResource
  self.model_class = ::Post
  self.title = :name

  def fields
    field :id, as: :id
    field :name, as: :text
  end
end
