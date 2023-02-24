class SiblingResource < Avo::BaseResource
  self.title = :name
  self.description = "Demo resource to illustrate Avo\'s Single Table Inheritance support (Sibling < Person)"
  self.includes = []
  self.model_class = ::Sibling
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end
  self.find_record_method = ->(model_class:, id:, params:) {
    model_class.find_by! name: id
  }

  field :id, as: :id
  field :name, as: :text
end
