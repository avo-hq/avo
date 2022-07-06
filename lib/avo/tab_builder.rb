class Avo::TabBuilder
  class << self
    def parse_block(**args, &block)
      Docile.dsl_eval(new(**args), &block).build
    end
  end

  attr_reader :items_holder

  delegate :field, to: :items_holder
  delegate :tool, to: :items_holder
  delegate :panel, to: :items_holder
  delegate :items, to: :items_holder

  def initialize(name: nil, **args)
    @tab = Avo::Tab.new(name: name, **args)
    @items_holder = Avo::ItemsHolder.new
  end

  # Fetch the tab
  def build
    @tab.items_holder = @items_holder
    @tab
  end
end
