require "rails_helper"

RSpec.describe "BatchDelete", type: :system do
  let!(:per_page) { 2 }
  let!(:courses) { create_list :course, per_page * 3 }
  let!(:url) { "/admin/resources/courses?per_page=#{per_page}" }

  context "select first record" do
    it "deletes the first record" do
      visit url
      check_first_record
      click_batch_delete
      click_on "Delete"

      expect(page).to have_text "1 record destroyed"
    end
  end

  context "select all records from first page" do
    it "deletes all records from first page" do
      visit url
      check_select_all
      click_batch_delete
      click_on "Delete"

      expect(page).to have_text "#{per_page} records destroyed"
    end
  end

  context "select all records from all pages" do
    it "deletes all records from all pages" do
      remaining_courses = Course.count
      visit url
      check_select_all
      click_on "Select all matching"
      click_batch_delete
      click_on "Delete"

      expect(page).to have_text "#{remaining_courses} records destroyed"
    end
  end
end

def check_select_all
  find(:css, 'input[type="checkbox"][data-action="input->item-select-all#toggle"]').set(true)
end

def check_first_record
  find(:css, 'input[type="checkbox"][data-action="input->item-selector#toggle input->item-select-all#selectRow"]', match: :first).set(true)
end

def click_batch_delete
  find(:css, 'a[data-item-select-all-target="batchDeleteButton"]').click
end
