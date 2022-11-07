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

  field :persistent_error, as: :boolean
  field :keep_text, as: :text

  def handle(**args)
    # Do something here

  # Test persistent error
  if args[:fields][:persistent_error]
    warn "We want this warning too."
    return persistent :info, "We want it to persist."
  end

    succeed "Success response ✌️"
    warn "Warning response ✌️"
    inform "Info response ✌️"
    fail "Error response ✌️"
  end
end
