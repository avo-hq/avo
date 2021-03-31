class ProjectResource < Avo::BaseResource
  self.title = :name
  self.search = [:name, :id]

  field :stage, as: :select, hide_on: [:index], enum: ::Project.stages, placeholder: "Choose the stage", display_value: true
end
