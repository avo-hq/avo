class Avo::Resources::CompactUser < Avo::BaseResource
  self.model_class = ::User
  self.find_record_method = -> {
    query.friendly.find id
  }

  def fields
    field :personal_information, as: :heading
    discover_columns only: [:first_name, :last_name, :birthday]

    field :heading, as: :heading, label: "Contact"
    discover_columns only: [:email]

    discover_associations only: [:posts]
  end
end
