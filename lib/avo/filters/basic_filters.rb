module Avo
  module Filters
    class BasicFilters
      def self.to_be_applied(resource:, applied_filters:)
        # Applied filters come from the `encoded_filters` param, which the user
        # carries around in the URL and (with session persistence on) in their
        # session. They outlive the code that produced them, so a filter that
        # has since been removed from `def filters` still shows up here.
        # Keeping only the declared ones is also what stops a hand-crafted
        # payload from naming an arbitrary constant for us to instantiate.
        declared_filters = resource.get_filters.index_by { |filter| filter[:class].to_s }

        filter_defaults = declared_filters.filter_map do |filter_class, filter|
          default = filter[:class].new(arguments: filter[:arguments]).default

          [filter_class, default] unless default.nil?
        end.to_h

        stale_filters = (applied_filters || {}).keys - declared_filters.keys

        if stale_filters.any?
          Avo.logger.warn "Avo: discarding filters that '#{resource.class}' doesn't declare in its `def filters` method: #{stale_filters.join(", ")}."
        end

        filter_defaults
          .merge(applied_filters || {})
          .slice(*declared_filters.keys)
      end
    end
  end
end
