require "rails_helper"

RSpec.describe "UserForms", type: :system do
  it "Shows the empty posts page" do
    visit "/admin/resources/posts"

    expect(page).to have_text("No posts found")
  end

  it "accesses the create user page" do
    visit "/admin/resources/users"

    click_on "Create new user"

    expect(page).to have_text("Create new user")
    expect(page).to have_text("First name")
    expect(page).to have_text("Last name")
    expect(page).to have_text("User Email")
    expect(page).to have_text("CV")
    expect(page).to have_text("Roles")
    expect(page).to have_text("Birthday")
    expect(page).to have_text("User Password")
    expect(page).to have_text("Password confirmation")
    expect(page).to have_text("Cancel")
    expect(page).to have_text("Save")
  end

  it "navigates back to the index page" do
    visit "/admin/resources/posts/new"

    click_on "Cancel"

    expect(page).to have_text "No posts found"
    expect(page).to have_css "a", text: "Create new post"
    expect(current_path).to eq "/admin/resources/posts"
  end

  it "displays valdation errors", skip_js_error_detect: true do
    visit "/admin/resources/users/new"

    click_on "Save"

    expect(page).to have_text("First name can't be blank")
    expect(page).to have_text("Last name can't be blank")
    expect(page).to have_text("Email can't be blank")
    expect(page).to have_text("Password can't be blank")
  end

  it "submits the form on enter", skip_js_error_detect: true do
    visit "/admin/resources/users/new"

    find("[data-field-id='first_name'] [data-slot='value'] input").native.send_keys(:return)

    expect(page).to have_text("First name can't be blank")
    expect(page).to have_text("Last name can't be blank")
    expect(page).to have_text("Email can't be blank")
    expect(page).to have_text("Password can't be blank")
  end

  it "creates a user" do
    visit "/admin/resources/users/new"

    fill_in "user_first_name", with: "John"
    fill_in "user_last_name", with: "Doe"
    fill_in "user_email", with: "john@doe.com"
    fill_in "user_password", with: "secret_password"
    fill_in "user_password_confirmation", with: "secret_password"

    click_on "Save"

    expect(page).to have_text("John")
    expect(page).to have_text("Doe")
    expect(page).to have_text("john@doe.com")
    user_id = page.find('[data-field-id="id"] [data-slot="value"]').text
    expect(current_path).to eq "/admin/resources/users/#{user_id}"

    within(".application-sidebar") do
      click_on "Users"
    end

    expect(page).to have_text("John")
    expect(page).to have_text("Doe")
    expect(current_path).to eq "/admin/resources/users"
  end
end
