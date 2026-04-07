class Avo::Scopes::ProjectOnHold < Avo::Advanced::Scopes::BaseScope
  self.name = "On hold"
  self.description = "Projects that are on hold"
  self.scope = -> { query.where(stage: "on hold") }
  self.visible = -> { true }
end
