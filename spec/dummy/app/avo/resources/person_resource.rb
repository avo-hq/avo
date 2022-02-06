class PersonResource < Avo::BaseResource
  self.title = :name
  self.description = 'People on the app'
  self.includes = []

  # self.search_query = ->(params:) do
  #   scope.ransack(id_eq: params[:q], m: "or").result(distinct: false)
  # end

  field :name, as: :text, link_to_resource: true
  field :type, as: :select, name: "Type", options: { Spouse: "Spouse" }
  field :link, as: :text, as_html: true do |model, &args|
    "<a href='https://avohq.io'>#{model.name}</a>"
  end
  field :spouses, as: :has_many
end
