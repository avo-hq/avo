class FishResource < Avo::BaseResource
  self.title = :name
  self.includes = []
  self.search_query = ->(params:) do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
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
