class CourseLinkResource < Avo::BaseResource
  self.title = :link
  self.includes = [:course]
  self.model_class = Course::Link
  # self.search_query = ->(params:) do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  field :link, as: :text
  field :course, as: :belongs_to, searchable: true
end
