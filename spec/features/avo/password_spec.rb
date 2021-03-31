require "rails_helper"

RSpec.feature "password", type: :feature do
  context "edit" do
    let(:url) { "/avo/resources/users/#{user.id}/edit" }

    subject do
      visit url
      find_field_value_element("password")
    end

    describe "with password set" do
      let(:old_password) { "foobar" }
      let(:new_password) { "new_foobar" }
      let!(:user) { create :user, password: old_password }

      it { is_expected.to have_field type: "password", id: "user_password", placeholder: "Password", text: nil }

      it "does not change the password" do
        visit url
        expect(page).to have_field type: "password", id: "user_password", placeholder: "Password", text: nil

        fill_in "user_first_name", with: "Johnny"

        click_on "Save"

        expect(current_path).to eql "/avo/resources/users/#{user.id}"
        expect(page).to have_text "Johnny"

        expect(user.valid_password?(old_password)).to be(true)
      end

      it "changes the password" do
        visit url
        expect(page).to have_field type: "password", id: "user_password", placeholder: "Password", text: nil

        fill_in "user_password", with: new_password

        click_on "Save"

        wait_for_loaded

        expect(current_path).to eql "/avo/resources/users/#{user.id}"

        expect(User.last.valid_password?(old_password)).to be(false)
        expect(User.last.valid_password?(new_password)).to be(true)
      end
    end
  end

  context "create" do
    let(:url) { "/avo/resources/users/new" }

    describe "new user with password" do
      it "checks placeholder" do
        visit url

        expect(page).to have_field type: "password", id: "user_password", placeholder: "Password", text: nil
        expect(page).to have_field type: "password", id: "user_password_confirmation", placeholder: "Password confirmation", text: nil
      end

      it "saves the resource with password" do
        visit url

        expect(page).to have_field type: "password", id: "user_password", placeholder: "Password", text: nil
        expect(page).to have_field type: "password", id: "user_password_confirmation", placeholder: "Password confirmation", text: nil

        fill_in "user_first_name", with: "John"
        fill_in "user_last_name", with: "Doe"
        fill_in "user_email", with: "johndoe@test.com"
        fill_in "user_password", with: "passwordtest"
        fill_in "user_password_confirmation", with: "passwordtest"

        click_on "Save"

        expect(current_path).to eql "/avo/resources/users/#{User.last.id}"
        expect(page).to have_text "John"
        expect(page).to have_text "Doe"
        expect(User.last.valid_password?("passwordtest")).to be(true)
      end
    end
  end
end
