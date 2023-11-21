class Avo::Resources::Sibling < Avo::BaseResource
  self.description = "Demo resource to illustrate Avo\'s Single Table Inheritance support (Sibling < Person)"
  self.model_class = ::Sibling
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false) }
  }
  self.find_record_method = -> {
    if id.to_i == 0
      # it's a string
      query.find_by! name: id
    else
      query.find id
    end
  }

  def fields
    field :id, as: :id
    field :name, as: :text
  end
end
