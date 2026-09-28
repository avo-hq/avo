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
    field :id, as: :id
    field :id, as: :number, only_on: :forms, readonly: -> { !view.new? }
    field :name, as: :text, required: -> { view.new? }, help: "help text"
    field :size, as: :radio, options: {small: "Small", "medium one": :Medium, "large two": :Large}, default: :Large
    field :secondary_field_for_name,
      as: :text,
      for_attribute: :name,
      only_on: :edit,
      help: "secondary field for name using for_attribute option"
    field :reviews, as: :has_many, per_page: 3
    # A belongs_to field posts the foreign key (fish[user_id]), so two fields for the same
    # association can not share a form: the regular field is used on new, the `for_attribute`
    # one on edit. Both render on index and show, where the table drops columns with the same
    # label, so the names must differ. Keep this one starting with "User": the create-modal specs
    # click "Create new user" on the edit form. See spec/system/avo/group_1/for_attribute_spec.rb
    field :user, as: :belongs_to, hide_on: :edit
    field :secondary_field_for_user,
      as: :belongs_to,
      for_attribute: :user,
      name: "User (for_attribute)",
      hide_on: :new,
      help: "secondary field for user using for_attribute option"
    field :type, as: :text, hide_on: :forms

    tool Avo::ResourceTools::NestedFishReviews, only_on: :new
    tool Avo::ResourceTools::FishInformation, show_on: :forms
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

      tab title: "big tab here 3" do
        card do
          field :id, as: :id
        end
      end

      tab title: "big tab here 3.5" do
        card do
          field :id, as: :id
        end
      end

      tab title: "tab here 4" do
        card do
          field :id, as: :id
        end
      end

      tab title: "tab" do
        card do
          field :id, as: :id
        end
      end

      tab title: "big useless tab here 6" do
        card do
          field :id, as: :id
        end
      end

      tab title: "big useless tab here 7" do
        card do
          field :id, as: :id
        end
      end

      tab title: "big tab 8" do
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
