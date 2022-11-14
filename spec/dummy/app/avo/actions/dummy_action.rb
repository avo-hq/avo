class DummyAction < Avo::BaseAction
  self.name = "Dummy action"
  self.standalone = true
  self.visible = -> do
    if resource.is_a? UserResource
      view == :index
    else
      true
    end
  end

  field :keep_modal_open, as: :boolean
  field :persistent_text, as: :text

  def handle(**args)
    # Test keep modal open
    if args[:fields][:keep_modal_open]
      succeed "Persistent success response ✌️"
      warn "Persistent warning response ✌️"
      inform "Persistent info response ✌️"
      error "Persistent error response ✌️"
      return keep_modal_open
    end

    succeed "Success response ✌️"
    warn "Warning response ✌️"
    inform "Info response ✌️"
    error "Error response ✌️"
  end
end
