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

  field :fail_and_keep_modal_open, as: :boolean
  field :keep_text, as: :text
  field :message, as: :trix, help: "Just testing."

  def handle(**args)
    # Do something here

    # Test keep modal open feature
    if args[:fields][:fail_and_keep_modal_open]
      fail "Error response and keep modal open ✌️", keep_modal_open: true
    end

    succeed "Success response ✌️"
    warn "Warning response ✌️"
    inform "Info response ✌️"
    fail "Error response ✌️"
  end
end
