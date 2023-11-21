module Avo
  module Resources
    module Controls
      class BaseControl
        attr_reader :label, :title, :color, :style, :icon, :icon_class, :confirmation_message, :size, :as_index_control

        def initialize(**args)
          @label = args[:label]
          @title = args[:title]
          @color = args[:color] || :gray
          @style = args[:style] || :text
          @icon = args[:icon]
          @icon_class = @style == :icon ? " text-gray-600 h-6 hover:text-gray-600" : ""
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
