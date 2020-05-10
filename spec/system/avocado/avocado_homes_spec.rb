require 'rails_helper'

RSpec.describe "Homes", type: :system do
  before do
    # driven_by(:rack_test)
    driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  end

  it "enables me to create widgets" do
    visit "/avocado"
    sleep 2

    fill_in "Name", :with => "My Widget"
    click_button "Create Widget"

    expect(page).to have_text("Widget was successfully created.")
  end
end
