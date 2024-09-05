module Avo
  module Concerns
    module ChecksShowAuthorization
      include Avo::Concerns::ChecksAssocAuthorization

      extend ActiveSupport::Concern

      def can_view?
        return false if Avo.configuration.resource_default_view.edit?

        return authorize_association_for(:show) if @reflection.present?

        # Even if there's a @reflection object present, for show we're going to fallback to the original policy.
        @resource.authorization.authorize_action(:show, raise_exception: false)
      end
    end
  end
end
