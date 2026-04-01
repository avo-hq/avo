require "rails_helper"

RSpec.feature "Actions", type: :system do
  it "shows the different types of alerts" do
    visit "/admin/resources/users"

    open_panel_action(action_name: "Dummy action")
    run_action

    expect(page).to have_selector ".alert.alert--danger"
    expect(page).to have_selector ".alert.alert--success"
    expect(page).to have_selector ".alert.alert--warning"
    expect(page).to have_selector ".alert.alert--info"

    expect(page).to have_text "Success response ✌️"
    expect(page).to have_text "Warning response ✌️"
    expect(page).to have_text "Info response ✌️"
    expect(page).to have_text "Error response ✌️"
  end
end
