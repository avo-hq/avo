class Avo::Resources::CompactUser < Avo::BaseResource
  self.model_class = ::User
  self.find_record_method = -> {
    query.friendly.find id
  }

  def fields
    field :personal_information, as: :heading

    field :first_name, as: :text
    field :last_name, as: :text
    field :birthday, as: :date

    field :heading, as: :heading, label: "Contact"

    field :email, as: :text

    field :posts, as: :has_many
  end
end
