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

  # For RSpec tabs_panels_and_sidebar_visibility_spec.rb
  tabs do
    field :hidden_field_inside_tabs, as: :text, visible: -> (resource:) {
      name = self.items_holder.items.first.items_holder.items.first.items.first.resource.model.name
      name == "RSpec TabsPanelAndSidebarVisibility"
    }

    tab "Hidden tab inside tabs" do
      field :hidden_field_inside_tabs_inside_tab, as: :text, visible: -> (resource:) {
        name = self.items_holder.items.first.resource.model.name
        name == "RSpec TabsPanelAndSidebarVisibility"
      }

      panel do
        field :hidden_field_inside_tabs_inside_tab_inside_panel, as: :text, visible: -> (resource:) {
          name = self.items_holder.items.first.resource.model.name
          name == "RSpec TabsPanelAndSidebarVisibility"
        }
      end
    end
  end

  sidebar do
    field :hidden_field_inside_sidebar, as: :text, visible: -> (resource:) {
      name = self.items.first.resource.model.name
      name == "RSpec TabsPanelAndSidebarVisibility"
    }
  end
end
