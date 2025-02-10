class Avo::Resources::Review < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }
  
  def fields
    field :id, as: :id
    field :reviewable_type, as: :text
    field :reviewable_id, as: :number
    field :body, as: :textarea
    field :user_id, as: :number
    field :reviewable, as: :belongs_to, polymorphic_as: :reviewable, types: [:Team, :Project, :Post, :Fish]
    field :user, as: :belongs_to
  end
end


