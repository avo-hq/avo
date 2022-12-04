require "rails_helper"

RSpec.describe Avo::SidebarProfileComponent, type: :component do
  before do
    allow_message_expectations_on_nil
    allow(Avo::App.license).to receive(:lacks_with_trial) { :menu_editor }.and_return(false)
  end

  describe 'destroy_user_session_path' do
    context 'with default configuration' do
      it "renders sign out link" do
        with_controller_class Avo::BaseController do
          render_inline(described_class.new(user: nil))
          expect(page).to have_css "form[action='/users/sign_out']", text: "Sign out"
        end
      end
    end

    context 'with missing route' do
      before do
        # Change the current_user_resource_name to generate a path
        # that does not exist
        Avo.configuration.current_user_resource_name = :missing
      end

      it "does not render sign out link" do
        with_controller_class Avo::BaseController do
          render_inline(described_class.new(user: nil))
          expect(page).to_not have_css "form", text: "Sign out"
        end
      end
    end

    context 'with current_user_resource_name' do
      before do
        without_partial_double_verification do
          # Stub an additional route
          allow(Rails.application.routes.url_helpers).to receive(:destroy_account_session_path).and_return("/accounts/sign_out")
        end

        Avo.configuration.current_user_resource_name = :account
      end

      after do
        Avo.configuration.current_user_resource_name = nil
      end

      it "renders sign out link" do
        with_controller_class Avo::BaseController do
          render_inline(described_class.new(user: nil))
          expect(page).to have_css "form[action='/accounts/sign_out']", text: "Sign out"
        end
      end
    end

    context 'with sign_out_path_name' do
      before do
        without_partial_double_verification do
          # Stub an additional route
          allow(Rails.application.routes.url_helpers).to receive(:sign_out_path_name).and_return("/custom/sign_out")
        end

        Avo.configuration.sign_out_path_name = :sign_out_path_name
      end

      after do
        Avo.configuration.sign_out_path_name = nil
      end

      it "renders sign out link" do
        with_controller_class Avo::BaseController do
          render_inline(described_class.new(user: nil))
          expect(page).to have_css "form[action='/custom/sign_out']", text: "Sign out"
        end
      end
    end
  end
end
