class Sub::DummyAction < Avo::BaseAction
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
  field :parent_id,
    as: :hidden,
    default: -> do
      # get_id(Avo::App.request.referer) # strip the id from the referer string
      1
    end
  field :parent_type,
    as: :hidden,
    default: -> do
      # get_type(Avo::App.request.referer) # strip the type from the referer string
      "users"
    end

  def handle(**args)
    # Test keep modal open
    if args[:fields][:keep_modal_open]
      succeed "Persistent success response ✌️"
      warn "Persistent warning response ✌️"
      inform "Persistent info response ✌️"
      error "Persistent error response ✌️"
      return keep_modal_open
    end

    if arguments[:special_message]
      succeed "I love 🥑"
    else
      succeed "Success response ✌️"
    end
    warn "Warning response ✌️"
    inform "Info response ✌️"
    error "Error response ✌️"
  end
end
