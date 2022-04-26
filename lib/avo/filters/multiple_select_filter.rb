module Avo
  module Filters
    class MultipleSelectFilter < BaseFilter
      self.template = "avo/base/multiple_select_filter"

      # The input expects an array of strings for the value
      # Ex: ['admins', 'non_admins']
      def selected_value(applied_filters)
        # Get the values for this particular filter
        applied_value = applied_filters[self.class.to_s]

        # Return that value if present
        return applied_value unless applied_value.nil?

        # Return that default
        return default unless default.nil?

        []
      end
    end
  end
end
