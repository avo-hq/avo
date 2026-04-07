class Avo::Scopes::ProjectCancelled < Avo::Advanced::Scopes::BaseScope
  self.name = "Cancelled"
  self.description = "Projects that are cancelled"
  self.scope = -> { query.where(stage: "cancelled") }
  self.visible = -> { true }
end
