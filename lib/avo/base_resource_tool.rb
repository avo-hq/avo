module Avo
  class BaseResourceTool
    prepend Avo::Concerns::IsResourceItem

    include Avo::Concerns::HasItemType
    include Avo::Concerns::IsVisible
    include Avo::Concerns::VisibleInDifferentViews

    class_attribute :name
    class_attribute :partial

    attr_accessor :params

    def initialize(**args)
      # Set the visibility
      only_on Avo.configuration.resource_default_view

      @args = args

      post_initialize if respond_to?(:post_initialize)
    end

    def partial
      return self.class.partial if self.class.partial.present?

      self.class.to_s.underscore
    end
  end
end
