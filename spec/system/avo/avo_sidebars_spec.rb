require 'rails_helper'

RSpec.describe "Sidebars", type: :system do
  it "is open by default" do
    visit "/admin/custom_tool"

    expect_sidebar_open

    toggle_menu

    expect_sidebar_closed

    reload_page

    expect_sidebar_closed

    reload_page

    expect_sidebar_closed

    toggle_menu

    expect_sidebar_open

    reload_page

    expect_sidebar_open
  end
end

def expect_sidebar_open
  expect(page).to have_selector ".avo-sidebar", visible: true
end

def expect_sidebar_closed
  expect(page).to have_selector ".avo-sidebar", visible: false
end

def toggle_menu
  find("[data-action='click->sidebar#toggleSidebar']").click
end
