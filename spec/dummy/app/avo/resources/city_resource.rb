# frozen_string_literal: true

class CityResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = -> {
    scope.ransack(name_eq: params[:q]).result(distinct: false)
  }
  self.search_result_path = -> {
    avo.resources_city_path record, custom: "yup"
  }
  self.extra_params = [city: [:name, :metadata, :coordinates, :city_center_area, :description, :population, :is_capital, :image_url, :tiny_description, :status, features: {}, metadata: {}]]
  self.default_view_type = :map
  self.map_view = {
    mapkick_options: {
      controls: true
    },
    record_marker: -> {
      {
        latitude: record.coordinates.first,
        longitude: record.coordinates.last,
        tooltip: record.name
      }
    },
    table: {
      visible: true,
      layout: :bottom
    }
  }

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
  field :description, as: :trix, attachment_key: :description_file, visible: ->(resource:) { resource.params[:show_native_fields].blank? }
  field :metadata,
    as: :code,
    format_using: -> {
      if view == :edit
        JSON.generate(value)
      else
        value
      end
    },
    update_using: -> do
      ActiveSupport::JSON.decode(value)
    end
  with_options hide_on: :forms do
    field :name, as: :text, help: "The name of your city"
    field :population, as: :number
    field :is_capital, as: :boolean
    field :features, as: :key_value
    field :image_url, as: :external_image
    field :tiny_description, as: :markdown
    field :status, as: :badge, enum: ::City.statuses
  end

  tool CityEditor, only_on: :forms
end
