require "rails_helper"

RSpec.describe Avo::SidebarProfileComponent, type: :component do
  before do
    allow_message_expectations_on_nil
  end

  describe "destroy_user_session_path" do
    context "with default configuration" do
      it "renders sign out link" do
        with_controller_class Avo::BaseController do
          render_inline(described_class.new(user: nil))
          expect(page).to have_css "form[action='/users/sign_out']", text: "Sign out", visible: :all
        end
      end
    end

    context "with missing route" do
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

    context "with current_user_resource_name" do
      before do
        without_partial_double_verification do
          # Stub an additional route
          allow(Rails.application.routes.url_helpers).to receive(:destroy_account_session_path).and_return("/accounts/sign_out")
        end

        Avo.configuration.current_user_resource_name = :account
      end

      after do
        Avo.configuration.current_user_resource_name = :user
      end

      it "renders sign out link" do
        with_controller_class Avo::BaseController do
          render_inline(described_class.new(user: nil))
          expect(page).to have_css "form[action='/accounts/sign_out']", text: "Sign out", visible: :all
        end
      end
    end

    context "with sign_out_path_name" do
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
          expect(page).to have_css "form[action='/custom/sign_out']", text: "Sign out", visible: :all
        end
      end
    end
  end

  describe "Avo Status" do
    it "shows a described badge on the menu button and a status item in the menu" do
      with_controller_class Avo::BaseController do
        render_inline(described_class.new(user: nil, show_status: true))

        expect(page).to have_css ".sidebar-profile__trigger .sidebar-status.sidebar-status--ok", visible: :all
        expect(page).to have_css ".sidebar-profile__trigger .sr-only", text: "Avo Status: ok", visible: :all
        expect(page).to have_css ".sidebar-profile__dropdown a[href='/admin/status']", text: "Avo Status", visible: :all
        expect(page).to have_css "a[href='/admin/status']", count: 1, visible: :all
      end
    end

    it "shows neither to users who can't see the status" do
      with_controller_class Avo::BaseController do
        render_inline(described_class.new(user: nil, show_status: false))

        expect(page).not_to have_css ".sidebar-status", visible: :all
        expect(page).not_to have_text "Avo Status"
      end
    end

    it "keeps the status item when avo-menu customizes the profile menu" do
      custom_menu = stub_const("CustomProfileMenuStub", Class.new(ViewComponent::Base) {
        def call = helpers.link_to("Custom item", "/custom")
      })
      allow_any_instance_of(described_class).to receive(:render_custom_profile_menu?).and_return(true)
      allow_any_instance_of(described_class).to receive(:custom_profile_component).and_return(custom_menu.new)

      with_controller_class Avo::BaseController do
        render_inline(described_class.new(user: nil, show_status: true))

        expect(page).to have_css ".sidebar-profile__dropdown a[href='/custom']", text: "Custom item", visible: :all
        expect(page).to have_css ".sidebar-profile__dropdown a[href='/admin/status']", text: "Avo Status", visible: :all
      end
    end
  end
end
