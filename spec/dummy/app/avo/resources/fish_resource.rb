class FishResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end

  self.show_controls = -> do
    back_button label: "", title: "Go back now"
    # TODO: add the ability to pass blocks to label and path
    link_to "Google", "https://google.com", icon: "heroicons/outline/academic-cap", target: :_blank
    link_to "Turbo demo", "/admin/resources/fish/#{params[:id]}?change_to=🚀🚀🚀 I told you it will change 🚀🚀🚀", turbo_frame: "fish_custom_action_demo"
    delete_button label: "", title: "something"
    detach_button label: "", title: "something"
    # actions_list exclude: ReleaseFish, style: :outline, color: :primary
    actions_list exclude: ReleaseFish
    action ReleaseFish, style: :primary, color: :fuchsia, icon: "heroicons/outline/globe"
    # link_to path: -> { params, resource, current_user }, label: -> { params, resource, current_user }, icon: "heroicons/outline/academic-cap", target: :_blank
    edit_button label: ""
  end

  field :id, as: :id
  field :name, as: :text, required: -> { view == :new }
  field :user, as: :belongs_to

  action DummyAction
  action ReleaseFish

  # tabs do
  #   tab "big useless tab here" do
  #     panel do
  #       field :id, as: :id
  #     end
  #   end

  #   tab "big useless tab here 2" do
  #     panel do
  #       field :id, as: :id
  #     end
  #   end

  #   tab "big useless tab here 3" do
  #     panel do
  #       field :id, as: :id
  #     end
  #   end

  #   tab "big useless tab here 4" do
  #     panel do
  #       field :id, as: :id
  #     end
  #   end

  #   tab "big useless tab here 5" do
  #     panel do
  #       field :id, as: :id
  #     end
  #   end

  #   tab "big useless tab here 6" do
  #     panel do
  #       field :id, as: :id
  #     end
  #   end

  #   tab "big useless tab here 7" do
  #     panel do
  #       field :id, as: :id
  #     end
  #   end

  #   tab "big useless tab here 8" do
  #     panel do
  #       field :id, as: :id
  #     end
  #   end
  # end


  tool FishInformation, show_on: :edit
end
