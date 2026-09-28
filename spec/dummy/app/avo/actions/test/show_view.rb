# Reports the view the action was started from, in the modal and in the
# success message, and declares a display-only field beside a hidden one so a
# spec can check that every declared field reaches the modal
# (avo-hq/avo#2190).
class Avo::Actions::Test::ShowView < Avo::BaseAction
  self.name = "Show view"
  self.standalone = true
  self.visible = -> { true }
  self.message = -> { "view=#{view} resource.view=#{resource.view}" }

  def fields
    field :probe_badge, as: :badge
    field :probe_hidden, as: :hidden, default: "hidden-default"
    field :probe_text, as: :text, default: -> { "text-default" }
  end

  def handle(fields:, **)
    succeed "view=#{view} resource.view=#{resource.view} probe_hidden=#{fields[:probe_hidden]}"
  end
end
