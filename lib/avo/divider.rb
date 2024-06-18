class Avo::Divider < Avo::BaseAction
  attr_reader :label, :view

  def initialize(label: nil, view: nil, **kwargs)
    @label = label
    @view = view
  end
end
