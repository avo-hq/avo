class Avo::Resources::Items::Header
  prepend Avo::Concerns::IsResourceItem

  include Avo::Concerns::HasItemType

  def initialize(**args)
    @args = args
  end

  def visible? = true
end
