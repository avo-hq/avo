class CourseResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end
  self.keep_filters_panel_open = true

  field :id, as: :id
  field :name, as: :text
  field :has_skills, as: :boolean, html: -> do
    edit do
      input do
        data({action: "input->resource-edit#toggle"})
      end
    end
  end
    # html: {
    #   wrapper: {
    #     # all wrappers
    #   },
    # # ->{
    #   edit: {
    #     input: {
    #       data: {},
    #     },
    #     wrapper: {
    #       data: {},
    #       class: '',
    #       style: {},
    #     },
    #     input: {
    #       data: { action: 'input->resource-edit#toggle'},
    #       class: '',
    #       style: {},
    #     }
    #   },
    #   show: {},
    #   index: {}
    # }
  # }
  # edit_html: {
  #   data: {},
  #   class: {},
  #   style: {},
  # }
  # html: -> {
  #   data do
  #     action 'input->resource-edit#toggle'
  #   end

  #   show do
  #     wrapper do

  #     end
  #   end
  # }
  field :skills, as: :tags, disallowed: -> { record.skill_disallowed }, suggestions: -> { record.skill_suggestions },
  # html: {
  #   data: {
  #     class: 'hidden',
  #     # 'resource-edit-target': 'skills'
  #   }
  # },
  html: -> do
    # all wrappers
    # data({something: :here})
    # classes('direct')



    # wrapper do
    #   data({something: :here})
    #   data({
    #     something: :here
    #   }) do
    #     # if record.id.present?
    #     #   {
    #     #     something: :present,
    #     #   }
    #     # else
    #     #   {
    #     #     something: :blank,
    #     #   }
    #     # end
    #     {something: "lol"}
    #   end
    #   classes 'hidden'
    #   style({
    #     color: :red
    #   })
    # end
    # input do
    #   data do
    #     # {second: :something }
    #     if record.id.present?
    #       {
    #         something: :present,
    #       }
    #     else
    #       {
    #         something: :blank,
    #       }
    #     end
    #   end
    # end
    # show do
    #   # abort 'in show'.inspect
    #   wrapper do
    #     data({
    #       something: :another
    #     })
    #   end
    # end



    edit do
      # abort 'in show'.inspect
      wrapper do
      #   data({
      #     edit: :wrapper
      #   })
        classes('hidden')
      end
      # input do
      #   data({
      #     edit: :input
      #   })
      # end
    end
  end
  field :country, as: :select, options: Course.countries.map { |country| [country, country] }.to_h
  field :city, as: :select, options: Course.cities.values.flatten.map { |city| [city, city] }.to_h
  field :links, as: :has_many, searchable: true, placeholder: "Click to choose a link"

  filter CourseCountryFilter
  filter CourseCityFilter
end
