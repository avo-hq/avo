require "rails_helper"

RSpec.describe "menu item behaviour", type: :feature do
  it "allows navigation via menu items" do
    visit "/"

    all("a", text: "Projects")[1].click

    expect(page).to have_current_path("/admin/resources/projects")

    all("a", text: "Users")[1].click

    expect(page).to have_current_path("/admin/resources/users?filters=eyJJc0FkbWluIjpbIm5vbl9hZG1pbnMiXX0%3D%0A")
  end
end
