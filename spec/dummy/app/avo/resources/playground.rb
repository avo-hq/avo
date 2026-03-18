class Avo::Resources::Playground < Avo::BaseResource
  self.title = :name
  self.description = "Showcase of non-relational Avo fields in a single resource."
  self.includes = []

  def fields
    field :preview, as: :preview
    field :id, as: :id
    field :avatar_url, as: :avatar, name: "Avatar"
    field :name, as: :text, required: true

    field :form_heading, as: :heading, name: "Form and scalar fields"
    field :hidden_token, as: :hidden
    field :password_value, as: :password, revealable: true
    field :boolean_value, as: :boolean, as_toggle: true
    field :number_value, as: :number, min: 0, max: 100, step: 1
    field :date_value, as: :date
    field :time_value, as: :time
    field :date_time_value, as: :date_time
    field :country_value, as: :country, include_blank: "No country"

    field :choice_heading, as: :heading, name: "Choice and status fields"
    field :select_value, as: :select, options: Playground::SELECT_OPTIONS
    field :multi_select_values, as: :select, multiple: true, options: Playground::MULTI_SELECT_OPTIONS
    field :radio_value, as: :radio, options: Playground::RADIO_OPTIONS
    field :badge_value, as: :badge, options: Playground::BADGE_OPTIONS
    field :status_value,
      as: :status,
      loading_when: Playground::STATUS_LOADING,
      failed_when: Playground::STATUS_FAILED,
      success_when: Playground::STATUS_SUCCESS,
      neutral_when: Playground::STATUS_NEUTRAL
    field :stars_value, as: :stars, max: 5
    field :progress_value, as: :progress_bar, max: 100, value_suffix: "%", display_value: true
    field :tags_values, as: :tags, suggestions: Playground::TAG_SUGGESTIONS
    field :boolean_group_values, as: :boolean_group, options: Playground::BOOLEAN_GROUP_OPTIONS

    field :structured_heading, as: :heading, name: "Structured and media fields"
    field :key_value_data, as: :key_value
    field :array_values, as: :array, only_on: [:index, :show] do
      Array.wrap(record.array_values)
    end
    field :external_image_url, as: :external_image
    field :gravatar_email, as: :gravatar, size: 48
    field :file_attachment, as: :file, is_image: true
    field :files_attachments, as: :files, is_image: true

    field :geo_heading, as: :heading, name: "Geo fields"
    field :location_coordinates, as: :location, stored_as: [:latitude, :longitude]
    field :area_coordinates, as: :area, geometry: :polygon

    field :content_heading, as: :heading, name: "Content fields"
    field :text_value, as: :text
    field :textarea_value, as: :textarea, rows: 4
    field :code_value, as: :code, language: "ruby", theme: "dracula", line_wrapping: true
    field :easy_mde_content, as: :easy_mde, height: "240px"
    field :tiptap_content, as: :tiptap
    field :trix_content, as: :trix
  end
end
