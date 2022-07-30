class TinyCommentResource < Avo::BaseResource
  self.title = :tiny_name
  self.includes = []
  self.model_class = ::Comment
  # self.search_query = ->(params:) do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :id, as: :id
  field :body, as: :textarea, format_using: ->(value) do
    if view == :show
      content_tag(:div, style: "white-space: pre-line") { value }
    else
      value
    end
  end
  field :tiny_name, as: :text, only_on: :index, as_description: true

end
