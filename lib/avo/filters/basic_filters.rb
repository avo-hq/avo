module Avo
  module Filters
    class BasicFilters
      def self.to_be_applied(resource:, applied_filters:)
        filter_defaults = {}

        resource.get_filters.each do |filter|
          filter_instance = filter[:class].new arguments: filter[:arguments]
          next if filter_instance.default.nil?

          filter_defaults[filter_instance.class.to_s] = filter_instance.default
        end

        filter_defaults.merge(applied_filters || {})
      end
    end
  end
end

