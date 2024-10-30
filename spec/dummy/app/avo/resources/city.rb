# frozen_string_literal: true

class Avo::Resources::City < Avo::BaseResource
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  }
  self.extra_params = [city: [:name, :metadata, :coordinates, :city_center_area, :description, :population, :is_capital, :image_url, :tiny_description, :status, features: {}, metadata: {}]]
  self.default_view_type = :map
  self.map_view = {
    mapkick_options: {
      controls: true
    },
    record_marker: -> {
      {
        latitude: record.latitude,
        longitude: record.longitude,
        tooltip: record.name
      }
    },
    extra_markers: -> do
      [
        {
          latitude: params[:lat] || 37.780411,
          longitude: params[:long] || -25.497047,
          label: "Açores",
          tooltip: "São Miguel",
          color: "#0F0"
        }
      ]
    end,
    table: {
      visible: true,
      layout: :bottom
    }
  }

  def base_fields
    field :id, as: :id
    field :coordinates, as: :location, stored_as: [:latitude, :longitude]
    field :city_center_area,
      as: :area,
      geometry: :polygon,
      mapkick_options: {
        style: "mapbox://styles/mapbox/satellite-v9",
        controls: true
      },
      datapoint_options: {
        label: "Paris City Center",
        tooltip: "Bonjour mes amis!",
        color: "#009099"
      }
    field :description,
      as: :trix,
      attachment_key: :description_file,
      visible: -> { resource.params[:show_native_fields].blank? }
    field :metadata,
      as: :code,
      format_using: -> {
        if view.edit?
          JSON.generate(value)
        else
          value
        end
      },
      update_using: -> do
        ActiveSupport::JSON.decode(value)
      rescue JSON::ParserError
      end

    field :created_at, as: :date_time, filterable: true
  end

  # Notice that even if those fields are hidden on the form, we still include them on `form_fields`.
  # This is because we want to be able to edit them using the tool.
  # When submitting the form, we need this fields declared on the resource in order to know how to process them and fill the record.
  def tool_fields
    field :name, as: :text, hide_on: [:index, :forms]
    with_options hide_on: :forms do
      field :name, as: :text, filterable: true, name: "name (click to edit)", only_on: :index do
        path, data = Avo::Actions::City::Update.link_arguments(
          resource: resource,
          arguments: {
            cities: [resource.record.to_param],
            render_name: true
          }
        )

        link_to resource.record.name, path, data: data
      end
      field :population, as: :number, filterable: true
      field :is_capital, as: :boolean, filterable: true
      field :features, as: :key_value
      field :image_url, as: :external_image
      field :tiny_description, as: :markdown
      field :status, as: :badge, enum: ::City.statuses
    end
  end

  def display_fields
    base_fields
    tool_fields
  end

  def form_fields
    base_fields
    tool_fields
    tool Avo::ResourceTools::CityEditor, only_on: :forms
  end

  def actions
    action Avo::Actions::City::PreUpdate
    action Avo::Actions::City::Update
    action Avo::Actions::Sub::DummyAction, arguments: {test_action_name: " city resource"}
  end
end
