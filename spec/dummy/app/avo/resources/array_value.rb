class Avo::Resources::ArrayValue < Avo::Resources::ArrayResource
  def fields
    field :value, as: :text
  end
end
