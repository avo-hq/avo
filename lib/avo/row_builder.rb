class Avo::RowBuilder
  class << self
    def parse_block(**args, &block)
      Docile.dsl_eval(new(**args), &block).build
    end
  end

  attr_reader :items_holder

  delegate :field, to: :items_holder
  delegate :tool, to: :items_holder
  delegate :items, to: :items_holder

  def initialize(**args)
    @row = Avo::Row.new(**args)
    @items_holder = Avo::ItemsHolder.new
  end

  # Fetch the tab
  def build
    @row.items_holder = @items_holder
    @row
  end
end
