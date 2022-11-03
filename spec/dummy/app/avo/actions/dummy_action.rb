class DummyAction < Avo::BaseAction
  self.name = "Dummy action"
  self.standalone = true
  self.visible = -> do
    #   Access to:
    #   block
    #   context
    #   current_user
    #   params
    #   parent_model
    #   parent_resource
    #   resource
    #   view
    #   view_context

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
