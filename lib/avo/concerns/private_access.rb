module Avo
  module Concerns
    module PrivateAccess
      extend ActiveSupport::Concern

      def can_access_private_status?
        return true if Rails.env.development?

        Avo::Current.user_is_developer? || Avo::Current.user_is_admin?
      end

      def authenticate_developer_or_admin!
        raise_404 unless can_access_private_status?
      end
    end
  end
end
