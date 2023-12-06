class Avo::Resources::Store < Avo::BaseResource
  self.includes = [:location]

  def fields
    field :id, as: :id
    field :name, as: :text
    field :size, as: :text

    # Example for error message when resource is missing
    field :location, as: :has_one
  end
end
