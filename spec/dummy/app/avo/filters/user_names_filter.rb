class Avo::Filters::UserNamesFilter < Avo::Filters::TextFilter
  self.name = -> { I18n.t("avo.filter_translations.user_names_filter.name") }
  self.button_label = -> { I18n.t("avo.filter_translations.user_names_filter.button_label") }
  self.empty_message = "Search by name"

  def apply(request, query, value)
    query.where("LOWER(first_name) like ?", "%#{value}%").or(query.where("LOWER(last_name) like ?", "%#{value}%"))
  end

  # def default
  #   'avo'
  # end
end
