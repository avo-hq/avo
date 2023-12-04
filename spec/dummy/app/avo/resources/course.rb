class Avo::Resources::Course < Avo::BaseResource
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false) }
  }
  self.keep_filters_panel_open = true
  self.stimulus_controllers = "course-resource toggle-fields"

  def fields

    field :id, as: :id
    field :name, as: :text, html: {
      edit: {
        input: {
          # classes: "bg-primary-500",
          data: {
            action: "input->resource-edit#debugOnInput"
          }
        },
        wrapper: {
          # style: "background: red;",
        }
      }
    }

    panel do
      field :has_skills, as: :boolean, filterable: true, html: -> do
        edit do
          input do
            # classes('block')
            data({
              # foo: record,
              # resource: resource,
              action: "input->resource-edit#toggle",
              resource_edit_toggle_target_param: "skills_textarea_wrapper",
              # resource_edit_toggle_targets_param: ["country_select_wrapper"]
            })
          end
        end
      end
      field :skills, as: :textarea
    end


    field :starting_at,
      as: :time,
      picker_format: "H:i",
      format: "HH:mm:ss z",
      timezone: -> { "Europe/Berlin" },
      picker_options: {
        hourIncrement: 1,
        minuteIncrement: 1,
        secondsIncrement: 1
      },
      filterable: true,
      relative: true

    field :country,
      as: :select,
      options: Course.countries.map { |country| [country, country] }.prepend(["-", nil]).to_h,
      html: {
        edit: {
          input: {
            data: {
              action: "course-resource#onCountryChange"
            }
          }
        }
      }
    field :city,
      as: :select,
      options: Course.cities.values.flatten.map { |city| [city, city] }.to_h,
      display_value: false

    field :links, as: :has_many, searchable: true, placeholder: "Click to choose a link",
      discreet_pagination: true
  end

  def filters
    filter Avo::Filters::CourseCountryFilter
    filter Avo::Filters::CourseCityFilter
  end
end
