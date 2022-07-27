class FishResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end
  self.extra_params = [:fish_type, :something_else, properties: []]

  field :id, as: :id
  field :name, as: :text, required: -> { view == :new }
  field :type, as: :text, hide_on: :forms

  tool FishInformation, show_on: :edit

  action DummyAction
end
