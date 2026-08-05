require "rails_helper"

RSpec.describe Avo::Concerns::PrivateAccess do
  let(:host) do
    Class.new do
      include Avo::Concerns::PrivateAccess

      def raise_404
        raise ActionController::RoutingError, "No route matches"
      end
    end.new
  end

  describe "#can_access_private_status?" do
    it "returns true in development" do
      allow(Rails.env).to receive(:development?).and_return(true)
      allow(Avo::Current).to receive(:user_is_developer?).and_return(false)
      allow(Avo::Current).to receive(:user_is_admin?).and_return(false)

      expect(host.can_access_private_status?).to be true
    end

    it "returns true in production for developer users" do
      allow(Rails.env).to receive(:development?).and_return(false)
      allow(Avo::Current).to receive(:user_is_developer?).and_return(true)
      allow(Avo::Current).to receive(:user_is_admin?).and_return(false)

      expect(host.can_access_private_status?).to be true
    end

    it "returns true in production for admin users" do
      allow(Rails.env).to receive(:development?).and_return(false)
      allow(Avo::Current).to receive(:user_is_developer?).and_return(false)
      allow(Avo::Current).to receive(:user_is_admin?).and_return(true)

      expect(host.can_access_private_status?).to be true
    end

    it "returns false in production for other users" do
      allow(Rails.env).to receive(:development?).and_return(false)
      allow(Avo::Current).to receive(:user_is_developer?).and_return(false)
      allow(Avo::Current).to receive(:user_is_admin?).and_return(false)

      expect(host.can_access_private_status?).to be false
    end
  end

  describe "#authenticate_developer_or_admin!" do
    it "does not raise in development" do
      allow(Rails.env).to receive(:development?).and_return(true)

      expect { host.authenticate_developer_or_admin! }.not_to raise_error
    end

    it "raises when the user cannot access private status in production" do
      allow(Rails.env).to receive(:development?).and_return(false)
      allow(Avo::Current).to receive(:user_is_developer?).and_return(false)
      allow(Avo::Current).to receive(:user_is_admin?).and_return(false)

      expect { host.authenticate_developer_or_admin! }.to raise_error(ActionController::RoutingError)
    end
  end
end
