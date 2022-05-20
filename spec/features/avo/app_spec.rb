require "rails_helper"

RSpec.describe "App", type: :feature do
  describe "Avo logo link" do
    it "redirects to the admin page" do
      visit "/admin"
      expect(current_path).to eq "/admin/dashboards/dashy"

      find(".logo-placeholder").click
      wait_for_loaded

      expect(current_path).to eq "/admin/dashboards/dashy"
    end
  end

  describe "custom tool works" do
    it "redirects to the admin page" do
      visit "/admin/dashboard"
      expect(current_path).to eq "/admin/dashboard"
    end
  end
end
