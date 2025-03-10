class Avo::Resources::Volunteer < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }
  def fields
    field :id, as: :id
    field :name, as: :text
    field :role, as: :text
    field :event_uuid, as: :text
  end
end
