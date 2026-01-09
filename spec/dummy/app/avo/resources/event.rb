class Avo::Resources::Event < Avo::BaseResource
  self.title = :name
  self.description = "An event that happened at a certain time."
  self.includes = [:location]

  self.cover = {
    # size: :sm,
    visible: [:show, :index],
    source: -> {
      if record.present?
        record.cover
      else
        Event.first&.cover
      end
    }
  }
  self.avatar = {
    source: :avatar
  }
  self.discreet_information = :timestamps

  self.row_controls_config = {
    float: true,
    show_on_hover: true,
    placement: :right
  }

  def fields
    field :avatar, as: :avatar
    field :name, as: :text, link_to_record: true, sortable: true, stacked: true
    field :first_user,
      as: :record_link,
      meta: -> {
        :foo
      }
    field :event_time, as: :datetime, sortable: true
    field :body,
      as: :trix,
      meta: {
        foo: :bar
      }

    field :avatar, as: :file, is_image: true, only_on: :forms
    field :cover, as: :file, is_image: true, only_on: :forms

    if params[:show_location_field] == "1"
      # Example for error message when resource is missing
      field :location, as: :belongs_to
    end

    # this field demonstrated how one can use the array field to display an arbitrary array of objects as a "has_many field"
    field :attendees, as: :array do
      # This is testing that array block can access the record.something
      record.attendees_from_block
    end
  end
end
