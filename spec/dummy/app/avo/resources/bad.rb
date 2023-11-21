class Avo::Resources::Bad < Avo::BaseResource
  self.title = :id
  self.includes = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    # add fields here
  end
end
