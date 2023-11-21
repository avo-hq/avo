class Avo::Resources::Person < Avo::BaseResource
  self.title = :name
  self.description = "Demo resource to illustrate Avo's Single Table Inheritance support (Spouse < Person)"
  self.includes = []

  self.link_to_child_resource = true
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :name, as: :text, link_to_record: true, sortable: true, stacked: true
    field :type, as: ::Pluggy::Fields::RadioField, name: "Type", options: {Spouse: "Spouse", Sibling: "Sibling"}, include_blank: true, filterable: true
    field :link, as: :text, as_html: true
    field :spouses, as: :has_many, hide_search_input: true
    field :relatives,
      as: :has_many,
      hide_search_input: true,
      link_to_child_resource: true,
      description: "People resources is using single table inheritance, we demonstrate the usage of link_to_child_resource.</br> If enabled like in this case, child resources will be used instead of parent resources"
    field :peoples,
      as: :has_many,
      hide_search_input: true,
      link_to_child_resource: false,
      description: "Default behaviour with link_to_child_resource disabled"
  end
end
