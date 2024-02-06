class Avo::Resources::Store < Avo::Resources::ActiveRecord
  self.includes = [:location]

  def fields
    field :id, as: :id
    field :name, as: :text
    field :size, as: :text

    if params[:show_location_field] == '1'
      # Example for error message when resource is missing
      field :location, as: :has_one
    end
  end
end
