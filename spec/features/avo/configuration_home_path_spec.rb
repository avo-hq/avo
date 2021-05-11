require "rails_helper"

RSpec.feature "Avo.configuration", type: :feature do
  describe ".home_path" do
    context "when set" do
      it "redirects to that path" do
        visit "/admin"

        expect(current_path).to eql "/admin/dashboard"
      end
    end
  end
end
