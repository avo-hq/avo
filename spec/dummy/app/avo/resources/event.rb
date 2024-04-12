class Avo::Resources::Event < Avo::BaseResource
  self.title = :name
  self.description = "An event that happened at a certain time."
  self.includes = [:location]

  def fields
    field :name, as: :text, link_to_record: true, sortable: true, stacked: true
    field :first_user, as: :record_link
    field :event_time, as: :datetime, sortable: true

    if params[:show_location_field] == "1"
      # Example for error message when resource is missing
      field :location, as: :belongs_to
    end
  end
end
