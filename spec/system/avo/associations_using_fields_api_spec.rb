# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Associations using *_fields api", type: :system do
  let!(:attach_link) { create :course_link }
  let!(:links) { create_list :course_link, 3 }
  let!(:course) { create :course, links: links }

  it "attach and detach works using show and index fields api" do
    visit avo.resources_course_path(course)

    scroll_to find('turbo-frame[id="has_many_field_show_links"]')

    click_on "Attach link"

    expect(page).to have_text "Choose link"

    select attach_link.link, from: "fields_related_id"

    expect {
      within '[aria-modal="true"]' do
        click_on "Attach"
      end
      wait_for_loaded
    }.to change(course.links, :count).by 1

    expect {
      accept_custom_alert do
        find("tr[data-resource-id='#{course.links.first.to_param}'] [data-control='detach']").click
      end
    }.to change(course.links, :count).by(-1)
  end

  context "when associations options exceeds associations_query_limit" do
    let!(:link) { Course::Link.first }

    before { Avo.configuration.associations_query_limit = 1 }
    after { Avo.configuration.associations_query_limit = 1000 }

    it "limits select options" do
      visit avo.resources_course_path(course)

      scroll_to find('turbo-frame[id="has_many_field_show_links"]')

      click_on "Attach link"

      expect(page).to have_select "fields_related_id", options: ["Choose an option", link.link, "There are more records available."]
      expect(page).to have_selector 'option[disabled="disabled"][value="There are more records available."]'
    end
  end
end
