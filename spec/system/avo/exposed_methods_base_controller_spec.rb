require "rails_helper"

RSpec.feature "ExposedMethodsBaseController", type: :system do
  describe "message" do
    let(:new_course_url) { "/admin/resources/courses/new" }
    let(:course_url) { "/admin/resources/courses/#{course.prefix_id}" }
    let(:course) { create :course }

    it "after_destroy_path && destroy_success_message" do
      visit course_url

      accept_alert do
        click_on "Delete"
      end
      wait_for_loaded

      expect(current_path).to eq new_course_url
      expect(page).to have_text "Course destroyed for ever!"
    end
  end
end
