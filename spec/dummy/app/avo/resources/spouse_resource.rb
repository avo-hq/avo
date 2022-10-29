class SpouseResource < Avo::BaseResource
  self.title = :name
  self.description = "Demo resource to illustrate Avo\'s Single Table Inheritance support (Spouse < Person)"
  self.includes = []
  self.model_class = ::Spouse
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  field :name, as: :text

  # Uncomment this to test visibility inside tabs, panels and sidebar
  # tabs do
  #   field :hidden_field_inside_tabs, as: :text, visible: -> (resource:) { false }

  #   tab "hidden testing visibility inside tabs" do
  #     field :hidden_field_inside_tabs_inside_tab, as: :text, visible: -> (resource:) { false }

  #     panel do
  #       field :hidden_field_inside_tabs_inside_tab_inside_panel, as: :text, visible: -> (resource:) { false }
  #     end
  #   end
  # end

  # sidebar do 
  #   field :hidden_field_inside_sidebar, as: :text, visible: -> (resource:) { false }
  #   field :field_inside_sidebar, as: :text
  # end

  # tabs do
  #   field :test_field_inside_tabs, as: :text

  #   tab "testing visibility inside tabs" do
  #     field :test_field_inside_tabs_inside_tab, as: :text

  #     panel do
  #       field :test_field_inside_tabs_inside_tab_inside_panel, as: :text
  #     end
  #   end
  # end
end
