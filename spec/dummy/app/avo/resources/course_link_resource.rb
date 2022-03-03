class CourseLinkResource < Avo::BaseResource
  self.title = :link
  self.includes = [:course]
  self.model_class = Course::Link
  # self.search_query = ->(params:) do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  self.ordering = {
    always_visible: true,
    actions: {
      higher: -> (record) { record.move_higher },
      lower: -> (record) { record.move_lower },
      to_top: -> (record) { record.move_to_top },
      to_bottom: -> (record) { record.move_to_bottom },
    }
  }

  field :id, as: :id
  field :link, as: :text
  field :course, as: :belongs_to, searchable: true
end
