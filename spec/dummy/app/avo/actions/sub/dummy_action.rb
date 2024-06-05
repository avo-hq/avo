class Avo::Actions::Sub::DummyAction < Avo::BaseAction
  self.name = -> { "Dummy action#{arguments[:test_action_name]}" }
  self.standalone = true
  # self.turbo = false
  self.visible = -> do
    if resource.is_a? Avo::Resources::User
      view.index?
    else
      true
    end
  end

  def fields
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

    field :fun_switch,
      as: :boolean_group,
      options: {
        yes: "Yes",
        sure: "Sure",
        why_not: "Why not"
      }
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
    elsif (fun_switch = args[:fields][:fun_switch].reject! { |option| option == "" }).any?
      succeed "#{fun_switch.map(&:humanize).join(", ")}, I love 🥑"
    else
      succeed "Success response ✌️"
    end
    warn "Warning response ✌️"
    inform "Info response ✌️"
    error "Error response ✌️"

    # redirect_to "https://www.google.com/"
  end
end
