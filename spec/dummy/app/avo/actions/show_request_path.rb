class Avo::Actions::ShowRequestPath < Avo::BaseAction
  self.name = "Show request path"
  self.confirmation = false
  self.visible = -> { true }

  def handle(request: nil, **)
    succeed request&.path.to_s
  end
end
