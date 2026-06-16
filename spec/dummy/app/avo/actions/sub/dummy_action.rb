class Avo::Actions::Sub::DummyAction < Avo::BaseAction
  self.name = -> { "Dummy action#{arguments[:test_action_name]}" }
  self.cancel_button_label = -> { arguments[:cancel_button_label] || I18n.t("avo.cancel") }
  self.confirm_button_label = -> { arguments[:confirm_button_label] || I18n.t("avo.run") }
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
    field :size, as: :radio, options: {small: "Small Option", medium: "Medium Option", large: "Large Option"}, default: :medium
    # Used to test that JS overlays are visible over the popup
    # field :date, as: :date, help: "<span title='hey' data-tippy='tooltip'>hey</span>"
    # field :tags, as: :tags, suggestions: -> { User.take(5).map { |user| {value: user.id, label: user.name} } }

    # Fields below are used to test the scrolling behavior of the modal.
    # field :size_2, as: :radio, options: {small: "Small Option", medium: "Medium Option", large: "Large Option"}, default: :medium
    # field :size_3, as: :radio, options: {small: "Small Option", medium: "Medium Option", large: "Large Option"}, default: :medium
    # field :size_4, as: :radio, options: {small: "Small Option", medium: "Medium Option", large: "Large Option"}, default: :medium
    # field :size_5, as: :radio, options: {small: "Small Option", medium: "Medium Option", large: "Large Option"}, default: :medium
    # field :size_6, as: :radio, options: {small: "Small Option", medium: "Medium Option", large: "Large Option"}, default: :medium
    # # field :size_7, as: :radio, options: {small: "Small Option", medium: "Medium Option", large: "Large Option"}, default: :medium
    # # field :size_8, as: :radio, options: {small: "Small Option", medium: "Medium Option", large: "Large Option"}, default: :medium
    # # field :size_9, as: :radio, options: {small: "Small Option", medium: "Medium Option", large: "Large Option"}, default: :medium
    # # field :size_10, as: :radio, options: {small: "Small Option", medium: "Medium Option", large: "Large Option"}, default: :medium

    TestBuddy.hi("Dummy action fields")
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
      succeed "I love 🥑", timeout: :forever
    elsif (fun_switch = args[:fields][:fun_switch].reject! { |option| option == "" }).any?
      succeed "#{fun_switch.map(&:humanize).join(", ")}, I love 🥑", timeout: :forever
    else
      succeed "Success response ✌️", timeout: :forever
    end
    warn "Warning response ✌️", timeout: 10000
    inform "Info response ✌️"
    error "Error response ✌️"

    # redirect_to "https://www.google.com/"
  end
end
