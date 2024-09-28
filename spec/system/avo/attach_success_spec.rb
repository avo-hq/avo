# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attachment success", type: :system do
  let!(:attach_link) { create :course_link }
  let!(:course) { create :course }

  it "attach works using show and index fields api" do
    visit avo.resources_course_path(course)

    click_on "Attach link"

    expect(page).to have_text "Choose link"

    select attach_link.link, from: "fields_related_id"

    expect {
      within '[aria-modal="true"]' do
        click_on "Attach"
      end
      wait_for_loaded
    }.to change(course.links, :count).by 1
  end
end
