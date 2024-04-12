class Avo::Resources::Message < Avo::BaseResource
  self.includes = []
  self.title = :subject
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :subject, as: :text
    field :body, as: :text
    field :entry, as: :record_link
  end
end
