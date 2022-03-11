class UserNamesFilter < Avo::Filters::TextFilter
  self.name = 'User names filter'
  self.button_label = 'Filter by user names'

  def apply(request, query, value)
    query.where('LOWER(first_name) like ?', "%#{value}%").or(query.where('LOWER(last_name) like ?', "%#{value}%"))
  end
end
