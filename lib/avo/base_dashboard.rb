module Avo
  class BaseDashboard
    extend ActiveSupport::DescendantsTracker

    class_attribute :id
    class_attribute :name
    class_attribute :description
    class_attribute :cards
    class_attribute :grid_cols, default: 3

    class << self
      def card(id, **args, &block)
        self.cards ||= []

        self.cards << ::Avo::Card.new(id: id, **args, dashboard: self, block: block)
      end
    end

    def classes
      case self.class.grid_cols
      when 3
        "grid-cols-3"
      when 4
        "grid-cols-4"
      when 5
        "grid-cols-5"
      when 6
        "grid-cols-6"
      else
        "grid-cols-3"
      end
    end

    def navigation_label
      self.class.name
    end

    def navigation_path
      "#{Avo::App.root_path}/dashboards/#{self.class.id}"
    end
  end
end
