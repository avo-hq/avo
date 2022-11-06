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
    if options[:special_message]
      succeed "I love 🥑"
    else
      succeed "Success response ✌️"
    end

    warn "Warning response ✌️"
    inform "Info response ✌️"
    fail "Error response ✌️"
  end
end
