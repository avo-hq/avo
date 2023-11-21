class Avo::Resources::Items::MainPanel < Avo::Resources::Items::Panel
  class Builder < Avo::Resources::Items::ItemGroup::Builder
    def initialize(parent: ,**args)
      @panel = Avo::Resources::Items::MainPanel.new(**args)
      @items_holder = Avo::Resources::Items::Holder.new(from: self.class, parent: parent)
    end
  end

  def visible?
    true
  end
end
