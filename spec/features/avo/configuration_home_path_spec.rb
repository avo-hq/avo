require "rails_helper"

RSpec.feature "Avo.configuration", type: :feature do
  describe ".home_path" do
    context "when set" do
      it "redirects to that path" do
        visit "/admin"
        expect(current_path).to eq "/admin/resources/projects"

        find(".logo-placeholder").click
        wait_for_loaded

        expect(current_path).to eq "/admin/resources/projects"
      end
    end
  end
end
