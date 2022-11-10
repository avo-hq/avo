require "rails_helper"

RSpec.feature "LicenseTinkeringInApplicationController", type: :feature do
  describe "check_avo_license" do
    context "without tinkering" do
      it "renders the response" do
        expect {
          visit "/admin/custom_tool"
        }.not_to raise_error
      end
    end

    context "with tinkering" do
      before do
        Avo::ToolsController.define_method :check_avo_license do
          ""
        end
      end

      after do
        Avo.send(:remove_const, :ToolsController)

        class Avo::ToolsController < Avo::ApplicationController
          def dashboard
            @page_title = "Dashboard"
            add_breadcrumb "Dashboard"
          end
        end
      end

      it "with tinkering" do
        expect {
          visit "/admin/custom_tool"
        }.to raise_error Avo::LicenseVerificationTemperedError
      end
    end
  end
end
