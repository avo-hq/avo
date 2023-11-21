class Avo::Resources::Fish < Avo::BaseResource
  self.includes = []
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false) }
  }
  self.extra_params = [:fish_type, :something_else, properties: [], information: [:name, :history], reviews_attributes: [:body, :user_id]]
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
    field :id, as: :id
    field :id, as: :number, only_on: :forms, readonly: -> { !view.new? }
    field :name, as: :text, required: -> { view.new? }, help: "help text"
    field :reviews, as: :has_many
    field :user, as: :belongs_to
    field :type, as: :text, hide_on: :forms

    tool Avo::ResourceTools::NestedFishReviews, only_on: :new
    tool Avo::ResourceTools::FishInformation, show_on: :forms
    tabs do
      tab "big useless tab here" do
        panel do
          field :id, as: :id
        end
      end

      tab "another big useless tab here 2" do
        panel do
          field :id, as: :id
        end
      end

      tab "big tab here 3" do
        panel do
          field :id, as: :id
        end
      end

      tab "big tab here 3.5" do
        panel do
          field :id, as: :id
        end
      end

      tab "tab here 4" do
        panel do
          field :id, as: :id
        end
      end

      tab "tab" do
        panel do
          field :id, as: :id
        end
      end

      tab "big useless tab here 6" do
        panel do
          field :id, as: :id
        end
      end

      tab "big useless tab here 7" do
        panel do
          field :id, as: :id
        end
      end

      tab "big tab 8" do
        panel do
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
