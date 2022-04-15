class CourseResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  field :name, as: :text
  field :skills, as: :tags, blacklist: -> { record.skill_blacklist }, suggestions: -> { record.skill_suggestions }
  field :links, as: :has_many, searchable: true, placeholder: "Click to choose a link"
end
