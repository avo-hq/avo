class Avo::Divider < Avo::BaseAction
  attr_reader :label

  def initialize(**kwargs)
    @label = kwargs[:label]
    @view = kwargs[:view]
  end
end
