class CompactUserResource < Avo::BaseResource
  self.title = :name
  self.model_class = ::User
  self.find_record_method = ->(model_class:, id:, params:) {
    model_class.friendly.find id
  }

  heading "personal information"
  field :first_name, as: :text
  field :last_name, as: :text
  field :birthday, as: :date
  heading "contact"
  field :email, as: :text
end
