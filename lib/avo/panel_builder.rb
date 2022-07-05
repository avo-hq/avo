class Avo::PanelBuilder
  class << self
    def parse_block(**args, &block)
      Docile.dsl_eval(new(**args), &block).build
    end
  end

  delegate :field, to: :items_holder
  delegate :items, to: :items_holder

  attr_reader :items_holder

  def initialize(name: nil, **args)
    @panel = Avo::Panel.new(name: name, **args)
    @items_holder = Avo::ItemsHolder.new
  end

  # Fetch the tab
  def build
    @panel.items_holder = @items_holder
    @panel
  end
end
