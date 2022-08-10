module Avo
  module Resources
    module Controls
      class BaseControl
        def initialize(**args)
          @args = args
        end

        def label
          @args[:label] || @label
        end

        def title
          @args[:title]
        end

        def color
          @args[:color] || :gray
        end

        def style
          @args[:style] || :text
        end

        def icon
          @args[:icon] || nil
        end

        def back_button?
          is_a? Avo::Resources::Controls::BackButton
        end

        def edit_button?
          is_a? Avo::Resources::Controls::EditButton
        end

        def delete_button?
          is_a? Avo::Resources::Controls::DeleteButton
        end

        def actions_list?
          is_a? Avo::Resources::Controls::ActionsList
        end

        def link_to?
          is_a? Avo::Resources::Controls::LinkTo
        end

        def detach_button?
          is_a? Avo::Resources::Controls::DetachButton
        end

        def action?
          is_a? Avo::Resources::Controls::Action
        end
      end
    end
  end
end
