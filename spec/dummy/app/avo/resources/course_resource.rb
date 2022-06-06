class CourseResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end
  self.keep_filters_panel_open = true
  self.stimulus_controllers = "course-resource"

  field :id, as: :id
  field :name, as: :text, html: {
    edit: {
      wrapper: {
        # style: "background: red"
      }
    }
  }
  field :has_skills, as: :boolean, html: -> do
    edit do
      input do
        data({
          foo: record,
          resource: resource,
          action: "input->resource-edit#toggle",
          resource_edit_toggle_target_param: "skills_tags_wrapper",
          # resource_edit_toggle_targets_param: ["country_select_wrapper"]
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
      input: {
        data: {
          course_resource_target: "countryFieldInput",
          action: "course-resource#onCountryChange"
        }
      }
    }
  }
  # field :city, as: :select, options: Course.cities.values.flatten.map { |city| [city, city] }.to_h, html: {
  # field :city, as: :text
  field :city, as: :select, options: Course.cities.values.flatten.map { |city| [city, city] }.to_h, placeholderw: 'qweq', display_value: false, html: {
    edit: {
      input: {
        data: {
          course_resource_target: "cityFieldInput"
        }
      },
      # wrapper: {
      #   classes: "hidden"
      # }
    }
  }
  field :links, as: :has_many, searchable: true, placeholder: "Click to choose a link"

  filter CourseCountryFilter
  filter CourseCityFilter
end
