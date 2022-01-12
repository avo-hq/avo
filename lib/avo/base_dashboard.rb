module Avo
  class BaseDashboard
    extend ActiveSupport::DescendantsTracker

    class_attribute :id
    class_attribute :name
    class_attribute :description

    def navigation_label
      self.class.name
    end

    def navigation_path
      "#{Avo::App.root_path}/dashboards/#{self.class.id}"
    end
  end
end
