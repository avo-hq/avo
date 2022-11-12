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

  field :persistent, as: :boolean
  field :persistent_text, as: :text

  def handle(**args)
    # Do something here

  # Test persistent error
  if args[:fields][:persistent]
    succeed "Persistent success response ✌️"
    warn "Persistent warning response ✌️"
    fail "Persistent error response ✌️"
    return persistent :info, "Persistent info response ✌️"
  end

    succeed "Success response ✌️"
    warn "Warning response ✌️"
    inform "Info response ✌️"
    fail "Error response ✌️"
  end
end
