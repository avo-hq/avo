class Avo::Filters::CommentBodyFilter < Avo::Filters::TextFilter
  self.name = "Comment body filter"

  def apply(request, query, value)
    query.where("body LIKE ?", "%#{value}%")
  end
end
