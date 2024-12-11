require "rails_helper"

RSpec.describe Avo::Concerns::HasFieldDiscovery, type: :system do
  let!(:user) { create :user, first_name: "John", last_name: "Doe", birthday: "1990-01-01", email: "john.doe@example.com" }
  let!(:post) { create :post, user: user, name: "Sample Post" }

  describe "Show Page" do
    let(:url) { "/admin/resources/field_discovery_users/#{user.slug}" }

    before { visit url }

    it "displays discovered columns correctly" do
      wait_for_loaded

      # Verify discovered columns
      expect(page).to have_text "FIRST NAME"
      expect(page).to have_text "John"
      expect(page).to have_text "LAST NAME"
      expect(page).to have_text "Doe"
      expect(page).to have_text "BIRTHDAY"
      expect(page).to have_text "1990-01-01"

      # Verify excluded fields are not displayed
      expect(page).not_to have_text "IS ADMIN?"
      expect(page).not_to have_text "CUSTOM CSS"
    end

    it "displays the email as a gravatar field with a link to the record" do
      within(".resource-sidebar-component") do
        expect(page).to have_css("img") # Check for avatar
      end
    end

    it "displays discovered associations correctly" do
      wait_for_loaded

      # Verify `posts` association
      expect(page).to have_text "Posts"
      expect(page).to have_text "Sample Post"
      expect(page).to have_link "Sample Post", href: "/admin/resources/posts/#{post.slug}?via_record_id=#{user.slug}&via_resource_class=Avo%3A%3AResources%3A%3AFieldDiscoveryUser"

      # Verify `cv_attachment` association is present
      expect(page).to have_text "CV ATTACHMENT"
    end
  end

  describe "Index Page" do
    let(:url) { "/admin/resources/field_discovery_users" }

    before { visit url }

    it "lists discovered fields in the index view" do
      wait_for_loaded

      within("table") do
        expect(page).to have_text "John"
        expect(page).to have_text "Doe"
        expect(page).to have_text user.slug
      end
    end
  end

  describe "Form Page" do
    let(:url) { "/admin/resources/field_discovery_users/#{user.id}/edit" }

    before { visit url }

    it "displays form-specific fields" do
      wait_for_loaded

      # Verify form-only fields
      expect(page).to have_field "User Password"
      expect(page).to have_field "Password confirmation"

      # Verify custom CSS field is displayed
      expect(page).to have_text "CUSTOM CSS"

      # Verify password fields allow input
      fill_in "User Password", with: "new_password"
      fill_in "Password confirmation", with: "new_password"
    end
  end
end
