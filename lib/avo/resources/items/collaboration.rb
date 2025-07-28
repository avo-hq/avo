class Avo::Resources::Items::Collaboration
  prepend Avo::Concerns::IsResourceItem

  include Avo::Concerns::HasItemType
  include Avo::Concerns::IsVisible
  include Avo::Concerns::VisibleInDifferentViews

  def initialize(**args)
    args.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end

    post_initialize if respond_to?(:post_initialize)
  end
end
