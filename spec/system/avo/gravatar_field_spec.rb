require "rails_helper"

RSpec.describe "GravatarFields", type: :system do
  describe "without gravatar (default image)" do
    let!(:user) { create :user }

    context "index" do
      it "displays the users avatar" do
        visit "/avo/resources/users"

        expect(first('[data-field-type="gravatar"]')).to have_selector "img"
        expect(first('[data-field-type="gravatar"]')).to have_css ".rounded-full"
        expect(first('[data-field-type="gravatar"]').find("img") ["src"]).to have_text "https://www.gravatar.com/avatar/"
        expect(first('[data-field-type="gravatar"]').find("img") ["src"]).to have_text "?default=&size=40"
      end
    end

    context "show" do
      it "displays the users name" do
        visit "/avo/resources/users/#{user.id}"

        expect(first('[data-field-type="gravatar"]')).to have_selector "img"
        expect(first('[data-field-type="gravatar"]')).not_to have_css ".rounded-full"
        expect(first('[data-field-type="gravatar"]').find("img") ["src"]).to have_text "https://www.gravatar.com/avatar/"
        expect(first('[data-field-type="gravatar"]').find("img") ["src"]).to have_text "?default=&size=340"
      end
    end
  end

  describe "with gravatar" do
    let!(:user) { create :user, email: "mihai.mdm2007@gmail.com" }

    context "index" do
      it "displays the users avatar" do
        visit "/avo/resources/users"

        expect(first('[data-field-type="gravatar"]')).to have_selector "img"
        expect(first('[data-field-type="gravatar"]')).to have_css ".rounded-full"
        expect(first('[data-field-type="gravatar"]').find("img") ["src"]).to have_text "https://www.gravatar.com/avatar/"
        expect(first('[data-field-type="gravatar"]').find("img") ["src"]).to have_text "?default=&size=40"
      end
    end

    context "show" do
      it "displays the users name" do
        visit "/avo/resources/users/#{user.id}"

        expect(first('[data-field-type="gravatar"]')).to have_selector "img"
        expect(first('[data-field-type="gravatar"]')).not_to have_css ".rounded-full"
        expect(first('[data-field-type="gravatar"]').find("img") ["src"]).to have_text "https://www.gravatar.com/avatar/"
        expect(first('[data-field-type="gravatar"]').find("img") ["src"]).to have_text "?default=&size=340"
      end
    end
  end
end
