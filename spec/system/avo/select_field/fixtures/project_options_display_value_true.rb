class ProjectResource < Avo::BaseResource
  self.title = :name
  self.search = [:name, :id]

  field :country, as: :select, options: {'Romania': "RO", 'Canada': "CA", 'India': "IN"}, display_value: true
end
