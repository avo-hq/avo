class Avo::Resources::Attendee < Avo::Resources::ArrayResource
  self.description = -> {
    return "Attendees from field block" if params["resource_name"] == "events"
    return "First 6 users" if params["resource_name"] == "courses"

    "#{@record&.name || "All the users"} rendered as array resource"
  }

  # Test array resource, this method should be called only on attendees index
  def records = User.all

  def fields
    field :id, as: :id
    field :avatar, as: :avatar
    field :name

    with_options visible: -> { !resource.record.is_a?(User) } do
      field :role
      field :organization
    end
  end
end
