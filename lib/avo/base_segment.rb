module Avo
  class BaseSegment
    class_attribute :query, default: nil
    class_attribute :columns, default: []
    class_attribute :fields
    class_attribute :name, default: nil

    puts 'in BaseLens'.inspect

    class << self
      def add_resource_fields
        # self.
      end
    end

    def initialize(resource:)
      @resource = resource
    end

    def name
      return self.class.name if self.class.name.present?

      self.class.to_s.underscore.humanize
    end

    def path
      self.class.to_s.underscore
    end

    def get_fields
      @resource.get_fields
    end

    # def hydrate(resource: resource)
    #   @resource = resource
    # end
  end
end
