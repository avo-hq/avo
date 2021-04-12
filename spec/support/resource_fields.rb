require "test_prof/recipes/rspec/before_all"

module TestHelpers
  module ResourceFields
    extend ActiveSupport::Concern

    included do
      let(:_resource_fields) { {} }

      def replace_field_declaration(klass, field_id, &block)
        _resource_fields[klass] = klass.fields
        klass.replace_field_declaration field_id, &block
      end

      def revert_to_original(klass)
        klass.fields = _resource_fields[klass]
      end
    end
  end
end
