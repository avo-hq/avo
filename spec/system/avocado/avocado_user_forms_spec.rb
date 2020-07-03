require 'rails_helper'

RSpec.describe 'UserForms', type: :system do
  it 'Shows the empty users page' do
    visit '/avocado/resources/users'

    expect(page).to have_text('No users found')
  end

  it 'accesses the create user page' do
    visit '/avocado/resources/users'

    click_on 'Create new user'

    expect(page).to have_text('Create new user')
    expect(page).to have_text('Name')
    expect(page).to have_text('Avatar')
    expect(page).to have_text('Description')
    expect(page).to have_text('Cancel')
    expect(page).to have_text('Save')
  end

  it 'navigates back to the index page' do
    visit '/avocado/resources/users/new'

    click_on 'Cancel'

    expect(page).to have_text 'No users found'
    expect(page).to have_css 'a.button', text: 'Create new user'
    expect(current_path).to eq '/avocado/resources/users'
  end

  it 'displays valdation errors', skip_js_error_detect: true do
    visit '/avocado/resources/users/new'

    click_on 'Save'

    expect(page).to have_text("Name can't be blank")
    expect(page).to have_text("Email can't be blank")
    expect(page).to have_text('Age is not a number')
    expect(page).to have_text("Description can't be blank")
  end

  it 'submits the form on enter', skip_js_error_detect: true do
    visit '/avocado/resources/users/new'

    find("[field-id='name'] [data-slot='value'] input").native.send_keys(:return)

    expect(page).to have_text("Name can't be blank")
    expect(page).to have_text("Email can't be blank")
    expect(page).to have_text('Age is not a number')
    expect(page).to have_text("Description can't be blank")
  end

  it 'creates a user' do
    visit '/avocado/resources/users/new'

    fill_in 'name', with: 'John Doe'
    fill_in 'email', with: 'john@doe.com'
    fill_in 'age', with: '21'
    fill_in 'description', with: 'Hey there,'
    fill_in 'password', with: 'secret_password'
    fill_in 'password_confirmation', with: 'secret_password'

    click_on 'Save'

    expect(page).to have_text('John Doe')
    expect(page).to have_text('john@doe.com')
    expect(page).to have_text('Hey there,')
    user_id = page.find('[field-id="id"] [data-slot="value"]').text
    expect(current_path).to eq "/avocado/resources/users/#{user_id}"

    click_on 'Users'

    expect(page).to have_text('John Doe')
    expect(current_path).to eq '/avocado/resources/users'
  end
end
