module Avo
  module Resources
    module Controls
      class BaseControl
        attr_reader :label

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

        def action?
          is_a? Avo::Resources::Controls::Action
        end
      end
    end
  end
end
