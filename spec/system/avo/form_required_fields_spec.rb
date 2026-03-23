require "rails_helper"

RSpec.describe "Form Required Fields", type: :system do
  describe "with a single required field" do
    it "disables the submit button on initial render when the required field is empty" do
      visit "/admin/resources/posts/new"

      submit_button = find('[data-form-target="submitButton"]')
      expect(submit_button).to be_disabled
    end

    it "enables the submit button when all required fields have values" do
      visit "/admin/resources/posts/new"

      fill_in "post_name", with: "My Post"

      submit_button = find('[data-form-target="submitButton"]')
      expect(submit_button).not_to be_disabled
    end
  end

  describe "with multiple required fields" do
    let!(:user) { create :user }

    it "keeps the submit button disabled when only one of the required fields has a value" do
      visit "/admin/resources/fish/new"

      fill_in "fish_name", with: "Nemo"
      # The required fields: user, fish_type, and properties are still empty

      submit_button = find('[data-form-target="submitButton"]')
      expect(submit_button).to be_disabled
    end
  end
end
