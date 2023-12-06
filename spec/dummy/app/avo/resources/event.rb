class Avo::Resources::Event < Avo::BaseResource
  self.title = :name
  self.description = "An event that happened at a certain time."
  self.includes = [:location]

  def fields
    field :name, as: :text, link_to_record: true, sortable: true, stacked: true
    field :event_time, as: :datetime, sortable: true

    # Example for error message when resource is missing
    field :location, as: :belongs_to
  end
end
