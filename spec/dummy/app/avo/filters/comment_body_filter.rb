class CommentBodyFilter < Avo::Filters::TextFilter
  self.name = "Comment body filter"
  self.button_label = "Filter by body"

  def apply(request, query, value)
    query.where("body LIKE ?", "%#{value}%")
  end
end
