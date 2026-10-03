require "rails_helper"

# The "Go back" button on a record page is a regular visit to the index, so the page is rendered from
# scratch rather than restored from Turbo's cache. The selection and scroll position should survive it.
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
end

def open_record_and_go_back(index)
  find(%(#{row_selector(index)} td[data-field-id="id"] a)).click
  expect(page).to have_current_path(%r{/admin/resources/fish/\d+})

  find('a[data-hotkey="b"]').click
  expect(page).to have_current_path("/admin/resources/fish?per_page=24")
end

def row_selector(index)
  %(tr[data-index="#{index}"])
end

def row_checkbox(index)
  find(%(#{record_selector_checkbox_selector}[data-index="#{index}"]))
end

def checked_row_indexes
  all(record_selector_checkbox_selector).select(&:checked?).map { |checkbox| checkbox[:"data-index"].to_i }.sort
end
