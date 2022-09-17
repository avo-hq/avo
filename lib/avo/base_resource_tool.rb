module Avo
  class BaseResourceTool
    include Avo::Concerns::IsResourceItem
    include Avo::Fields::FieldExtensions::VisibleInDifferentViews

    class_attribute :name
    class_attribute :partial
    class_attribute :item_type, default: :tool

    attr_accessor :params
    attr_accessor :resource
    attr_accessor :view

    def initialize(**args)
      # Set the visibility
      show_on :show

      show_on args[:show_on] if args[:show_on].present?
      hide_on args[:hide_on] if args[:hide_on].present?
      only_on args[:only_on] if args[:only_on].present?
      except_on args[:except_on] if args[:except_on].present?
    end

    def hydrate(view: nil)
      @view = view if view.present?

      self
    end

    def partial
      return self.class.partial if self.class.partial.present?

      "avo/resource_tools/#{self.class.to_s.underscore}"
    end
  end
end
