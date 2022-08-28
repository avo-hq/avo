module Avo
  module Fields
    module Concerns
      module IsRequired
        extend ActiveSupport::Concern

        def is_required?
          if required.respond_to? :call
            Avo::Hosts::ViewRecordHost.new(block: required, record: model, view: view).handle
          else
            required.nil? ? required_from_validators : required
          end
        end

        private

        def required_from_validators
          validators.any?{|validator| validator.kind_of?(ActiveModel::Validations::PresenceValidator)}
        end

        def validators
          model.class.validators_on(id)
        end
      end
    end
  end
end
