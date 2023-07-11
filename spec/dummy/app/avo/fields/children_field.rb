class ChildrenField < Avo::Fields::BaseField
  def initialize(name, **args, &block)
    super(name, **args, &block)

    @child_key = args[:child_key]
  end
end
