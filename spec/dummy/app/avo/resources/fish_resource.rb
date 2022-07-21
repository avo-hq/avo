class FishResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end

  self.show_controls = -> do
    back_button label: ""
    action DummyAction, style: :primary, color: :orange, icon: "heroicons/outline/academic-cap"
    action DummyAction, color: :fuchsia, label: "Another dummy action"
    delete_button label: "", title: "something"
    # TODO: add title attribute
    # TODO: add link_to
    actions_list filter_out: DummyAction
    # link_to path: "https://google.com", label: "Google", icon: "heroicons/outline/academic-cap", target: :_blank
    # link_to path: -> { params, resource, current_user }, label: -> { params, resource, current_user }, icon: "heroicons/outline/academic-cap", target: :_blank
    edit_button label: ""
  end

  field :id, as: :id
  field :name, as: :text, required: -> { view == :new }

  tool FishInformation, show_on: :edit

  action DummyAction
end
