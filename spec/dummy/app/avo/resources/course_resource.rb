class CourseResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end
  self.keep_filters_panel_open = true
  self.stimulus_controllers = "dummy-custom"

  field :id, as: :id
  field :name, as: :text
  field :has_skills, as: :boolean, html: -> do
    edit do
      input do
        data({
          action: "input->resource-edit#toggle",
          resource_edit_toggle_field_param: "skills_tags",
          resource_edit_toggle_fields_param: ["country_select"]
        })
      end
    end
  end
  field :skills, as: :tags, disallowed: -> { record.skill_disallowed }, suggestions: -> { record.skill_suggestions }, html: {
    edit: {
      wrapper: {
        classes: "hidden"
      }
    }
  }
  field :country, as: :select, options: Course.countries.map { |country| [country, country] }.to_h, html: {
    edit: {
      wrapper: {
        classes: "hidden"
      }
    }
  }
  field :city, as: :select, options: Course.cities.values.flatten.map { |city| [city, city] }.to_h
  field :links, as: :has_many, searchable: true, placeholder: "Click to choose a link"

  filter CourseCountryFilter
  filter CourseCityFilter
end
