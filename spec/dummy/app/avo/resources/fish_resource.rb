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

  action DummyAction

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

  tool FishInformation, show_on: :edit
end
