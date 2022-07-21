module Avo
  module Resources
    module Controls
      class DeleteButton < BaseControl
        def initialize(**args)
          @label = args[:label] || I18n.t('avo.delete').capitalize
        end
      end
    end
  end
end
