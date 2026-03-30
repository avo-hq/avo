class Avo::Resources::Fish < Avo::BaseResource
  self.includes = []
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false) }
  }
  self.extra_params = [:fish_type, :something_else, properties: [], information: [:name, :history, :age], reviews_attributes: [:body, :user_id]]
  self.view_types = -> do
    if current_user.is_admin?
      [:table, :grid]
    else
      :table
    end
  end
  self.grid_view = {
    card: -> do
      {
        title: record.name
      }
    end
  }

  def fields
    tabs visible: true do
      tab title: "big useless tab here" do
        card do
          field :id, as: :id
        end
      end

      tab title: "another big useless tab here 2" do
        card do
          field :id, as: :id
        end
      end
    end
  end

  def filters
    filter Avo::Filters::NameFilter, arguments: {
      case_insensitive: true
    }
  end

  def actions
    if view.index?
      action Avo::Actions::Sub::DummyAction, arguments: -> do
        {
          special_message: resource.view.index? && current_user.is_admin?
        }
      end
    end
    action Avo::Actions::ReleaseFish
  end
end
