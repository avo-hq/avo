require "rails_helper"

RSpec.feature "ExposedMethodsBaseController", type: :feature do
  describe "message" do

    let(:new_course_url) { "/admin/resources/courses/new" }

    it "create_fail_message" do
      visit new_course_url

      save_and_wait_for_loaded

      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_text "Course not created!"
    end

    it "create_success_message" do
      visit new_course_url

      fill_in "course_name", with: "Great Course"
      save_and_wait_for_loaded

      expect(current_path).to eq "/admin/resources/courses/#{Course.last.id}"
      expect(page).to have_text "Course created!"
    end

    let(:course) { create :course }
    let(:edit_course_url) { "/admin/resources/courses/#{course.id}/edit" }

    it "update_fail_message" do
      visit edit_course_url

      fill_in "course_name", with: ""
      save_and_wait_for_loaded

      expect(page).to have_http_status(:unprocessable_entity)
      expect(page).to have_text "Course not updated!"
      expect(page).to have_text "Validation failed: Name can't be blank"
    end

    let(:course_url) { "/admin/resources/courses/#{course.id}" }

    it "update_success_message" do
      visit edit_course_url

      fill_in "course_name", with: "Guitar Course"
      save_and_wait_for_loaded

      expect(current_path).to eq course_url
      expect(page).to have_text "Course updated!"
    end

    it "after_destroy_path && destroy_success_message" do
      visit course_url

      click_on "Delete"
      wait_for_loaded

      expect(current_path).to eq new_course_url
      expect(page).to have_text "Course destroyed for ever!"
    end
  end
end

def save_and_wait_for_loaded
  click_on "Save"
  wait_for_loaded
end
