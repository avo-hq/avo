class Avo::Resources::Items::Card < Avo::Resources::Items::ItemGroup
  class Builder < Avo::Resources::Items::ItemGroup::Builder
    def initialize(parent:, title: nil, **args)
      @card = Avo::Resources::Items::Card.new(title: title, **args)
      @items_holder = Avo::Resources::Items::Holder.new(from: self.class, parent: parent)
    end

    # Fetch the card
    def build
      @card.items_holder = @items_holder
      @card
    end
  end
end
