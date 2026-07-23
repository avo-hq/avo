module Avo
  module Resources
    module Controls
      class BaseControl
        # Keys the control consumes itself, either as an option it renders from
        # (`style`, `icon`…) or as internal plumbing merged in by `execute_block`
        # (`as_index_control`, `item`…). Everything a user passes *outside* this
        # list is forwarded to the rendered element as an HTML attribute, so
        # `link_to "Docs", url, rel: "noopener"` reaches the `<a>` tag.
        CONTROL_OPTIONS = %i[
          label path title target data class
          style color size icon icon_class confirmation_message
          as_index_control from_custom_list item
        ].freeze unless defined?(CONTROL_OPTIONS)

        attr_reader :label, :title, :color, :style, :icon, :icon_class, :confirmation_message, :size, :as_index_control

        def initialize(**args)
          @label = args[:label]
          @title = args[:title]
          @color = args[:color] || :gray
          @style = args[:style] || :text
          @icon = args[:icon]
          @icon_class = (@style == :icon) ? " text-gray-600 h-6 hover:text-gray-600" : ""
          @confirmation_message = args[:confirmation_message]
          @size = args[:size] || :md
          @as_index_control = args[:as_index_control]
        end

        def type
          self.class.name.demodulize.underscore.to_sym
        end
      end
    end
  end
end
