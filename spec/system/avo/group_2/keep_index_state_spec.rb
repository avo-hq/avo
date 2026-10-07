require "rails_helper"

# Going back to the index, with the "Go back" button on a record page or the browser's Back button, puts the
# selection and scroll position back. "Go back" is a regular visit, so the page is rendered from scratch
# rather than restored from Turbo's cache. Reaching the index any other way starts fresh.
RSpec.describe "KeepIndexState", type: :system do
  let!(:fishes) { create_list :fish, 24 }

  before do
    visit "/admin/resources/fish?per_page=24"

    expect(page).to have_selector record_selector_checkbox_selector, count: fishes.size
  end

  it "keeps the selected rows after going back from a record" do
    row_checkbox(1).click
    row_checkbox(3).click

    open_record_and_go_back(20)

    expect(checked_row_indexes).to eq [1, 3]
    expect(page).to have_css "#{row_selector(1)}.selected-row"
  end

  it "keeps the scroll position after going back from a record" do
    page.execute_script("window.scrollTo(0, 400)")
    scroll_position = page.evaluate_script("window.scrollY")
    expect(scroll_position).to be > 0

    open_record_and_go_back(20)

    expect(page).to have_selector record_selector_checkbox_selector, count: fishes.size
    expect(page.evaluate_script("window.scrollY")).to eq scroll_position
  end

  it "forgets the selection once an action runs on it" do
    row_checkbox(1).click

    open_panel_action(action_name: "Release fish")
    run_action
    expect(page).to have_text "1 fish released"

    open_record_and_go_back(20)

    expect(checked_row_indexes).to be_empty
  end

  it "keeps the selected rows after the browser's Back button" do
    row_checkbox(1).click

    open_record(20)
    page.go_back
    expect(page).to have_current_path("/admin/resources/fish?per_page=24")

    expect(checked_row_indexes).to eq [1]
  end

  it "starts fresh when the index is reached another way, and forgets the selection" do
    row_checkbox(1).click

    open_record(20)
    page.execute_script("Turbo.visit('/admin/resources/fish?per_page=24')")
    expect(page).to have_current_path("/admin/resources/fish?per_page=24")
    expect(page).to have_selector record_selector_checkbox_selector, count: fishes.size
    expect(checked_row_indexes).to be_empty

    open_record_and_go_back(20)

    expect(checked_row_indexes).to be_empty
  end

  def open_record(index)
    find(%(#{row_selector(index)} td[data-field-id="id"] a)).click
    expect(page).to have_current_path(%r{/admin/resources/fish/\d+})
  end

  def open_record_and_go_back(index)
    open_record(index)

    find("a[data-go-back]").click
    expect(page).to have_current_path("/admin/resources/fish?per_page=24")
  end
end
