# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attach and atach another", type: :system do
  let!(:project) { create(:project) }
  let!(:comments) { create_list(:comment, 2) }

  it "attaches 2 comments without closing the modal" do
    visit avo.resources_project_path(project)

    scroll_to find('turbo-frame[id="has_many_field_show_comments"]')

    click_on("Attach comment")

    select comments.first.tiny_name, from: "fields_related_id"

    expect {
      within '[aria-modal="true"]' do
        click_on "Attach & Attach another"
      end
      wait_for_loaded
    }.to change(project.comments, :count).by 1

    select comments.second.tiny_name, from: "fields_related_id"

    expect {
      within '[aria-modal="true"]' do
        click_on "Attach & Attach another"
      end
      wait_for_loaded
    }.to change(project.comments, :count).by 1

    expect(page).to have_text("Comment attached.").twice
  end
end
