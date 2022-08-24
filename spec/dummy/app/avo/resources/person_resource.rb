class PersonResource < Avo::BaseResource
  self.title = :name
  self.description = "Demo resource to illustrate Avo's Single Table Inheritance support (Spouse < Person)"
  self.includes = []

  # self.search_query = -> do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :name, as: :text, link_to_resource: true, sortable: true
  field :type, as: :select, name: "Type", options: {Spouse: "Spouse"}, include_blank: true
  field :link, as: :text, as_html: true do |model, &args|
    "<a href='https://avohq.io'>#{model.name}</a>"
  end
  field :spouses, as: :has_many, hide_search_input: true
end
