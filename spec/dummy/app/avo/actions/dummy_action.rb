class DummyAction < Avo::BaseAction
  self.name = "Dummy action"
  self.standalone = true
  self.visible = ->(resource:, view:) do
    if resource.is_a? UserResource
      view == :index
    else
      true
    end
  end

  def handle(**args)
    # Do something here

    succeed "Success response ✌️"
    warn "Warning response ✌️"
    inform "Info response ✌️"
    fail "Error response ✌️"
  end
end
