class Avo::Resources::Store < Avo::BaseResource
  self.includes = [:location]
  self.confirm_on_save = true

  def fields
    field :id, as: :id
    field :name, as: :text
    field :size, as: :text

    if params[:show_location_field] == "1"
      # Example for error message when resource is missing
      field :location, as: :has_one
    end

    field :patrons,
      as: :has_many,
      through: :patronships,
      translation_key: "patrons",
      attach_fields: -> {
        field :review, as: :text
      }
  end
end
