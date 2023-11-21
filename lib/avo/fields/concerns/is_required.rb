module Avo
  module Fields
    module Concerns
      module IsRequired
        extend ActiveSupport::Concern

        def is_required?
          return required_from_validators if required.nil?

          Avo::ExecutionContext.new(target: required, record: record, view: view, resource: resource).handle
        end

        private

        def required_from_validators
          return false if record.nil?

          validators.any? do |validator|
            validator.is_a? ActiveModel::Validations::PresenceValidator
          end
        end

        def validators
          record.class.validators_on(id)
        end
      end
    end
  end
end
