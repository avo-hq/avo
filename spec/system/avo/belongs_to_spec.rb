require "rails_helper"

RSpec.feature "belongs_to", type: :system do
  context "new" do
    describe "with belongs_to foreign key field disabled" do
      let!(:course) { create :course }

      it "saves the related comment" do
        expect(Course::Link.count).to be 0

        visit "/admin/resources/course_links/new?via_relation=course&via_relation_class=Course&via_resource_id=#{course.id}"

        fill_in "course_link_link", with: "https://avo.cool"

        click_on "Save"
        wait_for_loaded

        # When the validation fails for any reason, the user is redirected to this weird `/new` path with the newly created model populating the form
        # This test is valid only as a system test. The feature test does not cover this edge-case
        expect(current_path).not_to eq "/admin/resources/course_links/new"
        expect(Course::Link.count).to be 1
        expect(Course::Link.first.course_id).to eq course.id
      end
    end
  end
end
