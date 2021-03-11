class Avo::ActionsLoader
  attr_accessor :bag

  def initialize
    @bag = []
  end

  def use(klass)
    @bag.push klass
  end
end
