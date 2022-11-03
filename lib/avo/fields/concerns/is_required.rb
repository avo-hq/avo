module Avo
  module Fields
    module Concerns
      module IsRequired
        extend ActiveSupport::Concern

        def is_required?
          if required.respond_to? :call
            Avo::Hosts::ResourceViewRecordHost.new(block: required, record: model, view: view, resource: resource).handle
          else
            required.nil? ? required_from_validators : required
          end
        end

        private

        def required_from_validators
          return false if model.nil?

          validators.any? do |validator|
            validator.is_a? ActiveModel::Validations::PresenceValidator
          end
        end

        def validators
          model.class.validators_on(id)
        end
      end
    end
  end
end
