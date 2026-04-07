class Avo::Scopes::ProjectDone < Avo::Advanced::Scopes::BaseScope
  self.name = "Done"
  self.description = "Projects that are done"
  self.scope = -> { query.where(stage: "done") }
  self.visible = -> { true }
end
