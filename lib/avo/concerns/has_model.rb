module Avo
  module Concerns
    module HasModel
      extend ActiveSupport::Concern

      def has_model_id?
        model.present? && model.id.present?
      end
    end
  end
end
