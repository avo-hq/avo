require "rails_helper"

# https://github.com/avo-hq/avo/issues/3029
RSpec.describe "Actions after navigating back", type: :system do
  let!(:fish) { create_list :fish, 2 }

  it "runs the action on the records selected after the browser back button" do
    visit avo.resources_fish_index_path

    find(:css, record_selector_checkbox_selector, match: :first).set(true)
    open_panel_action(action_name: "Release fish")
    run_action
    expect(page).to have_text "1 fish released"

    first('a[data-control="show"]').click
    expect(page).to have_current_path(%r{#{avo.resources_fish_index_path}/\d+})
    page.go_back
    wait_for_path_to_be(path: avo.resources_fish_index_path)

    all(:css, record_selector_checkbox_selector).each { |checkbox| checkbox.set(true) }
    open_panel_action(action_name: "Release fish")
    run_action

    expect(page).to have_text "2 fish released"
  end
end
