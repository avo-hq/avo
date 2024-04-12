class Avo::Resources::Entry < Avo::BaseResource
  self.includes = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    # field :entryable, as: :delegation, polymorphic_as: %w[Message Activity]
    # field :entryable_type, as: :has_many, polymorphic_as: %w[Message Activity]
    field :entryable_type, as: :select, options: %w[Message Activity]
    field :entryable_id, as: :number
    field :entryable, as: :delegated_type
  end
end
