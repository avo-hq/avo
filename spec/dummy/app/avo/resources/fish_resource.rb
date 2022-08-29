class FishResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end
  self.extra_params = [:fish_type, :something_else, properties: [], information: [:name, :history]]

  self.show_controls = -> do
    back_button label: "", title: "Go back now"
    link_to "Fish.com", "https://fish.com", icon: "heroicons/outline/academic-cap", target: :_blank
    link_to "Turbo demo", "/admin/resources/fish/#{params[:id]}?change_to=🚀🚀🚀 I told you it will change 🚀🚀🚀",
      class: ".custom-class",
      data: {
        turbo_frame: "fish_custom_action_demo"
      }
    delete_button label: "", title: "something"
    detach_button label: "", title: "something"
    actions_list exclude: ReleaseFish, style: :primary, color: :slate
    action ReleaseFish, style: :primary, color: :fuchsia, icon: "heroicons/outline/globe"
    edit_button label: ""
  end

  field :id, as: :id
  field :id, as: :number, only_on: :forms, readonly: -> { view != :new }
  field :name, as: :text, required: -> { view == :new }
  field :user, as: :belongs_to
  field :type, as: :text, hide_on: :forms

  filter NameFilter

  action DummyAction
  action ReleaseFish

  tool FishInformation, show_on: :forms

  tabs do
    tab "big useless tab here" do
      panel do
        field :id, as: :id
      end
    end

    tab "big useless tab here 2" do
      panel do
        field :id, as: :id
      end
    end

    tab "big useless tab here 3" do
      panel do
        field :id, as: :id
      end
    end

    tab "big useless tab here 4" do
      panel do
        field :id, as: :id
      end
    end

    tab "big useless tab here 5" do
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

    tab "big useless tab here 8" do
      panel do
        field :id, as: :id
      end
    end
  end
end
