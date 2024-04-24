class Avo::Resources::Spouse < Avo::BaseResource
  self.description = "Demo resource to illustrate Avo\'s Single Table Inheritance support (Spouse < Person)"
  self.model_class = ::Spouse
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false) }
  }

  def fields
    field :id, as: :id
    field :name, as: :text
  end
end
