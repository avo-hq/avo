require "rails_helper"

RSpec.describe "Cmd/Ctrl+Return in a modal", type: :system do
  around do |example|
    original = Avo.configuration.hotkeys
    Avo.configuration.hotkeys = {enabled: true, show_key_badges: true}
    example.run
    Avo.configuration.hotkeys = original
  end

  let!(:user) { create :user }

  def count_dummy_action_runs
    runs = 0
    allow_any_instance_of(Avo::Actions::Sub::DummyAction)
      .to receive(:handle).and_wrap_original do |original, *args, **kwargs|
      runs += 1
      original.call(*args, **kwargs)
    end
    -> { runs }
  end

  def open_dummy_action
    visit "/admin/resources/users"
    click_on "Actions"
    click_on "Dummy action"
    expect(page).to have_selector("[role='dialog']")
  end

  # Focus the modal container itself: Return on a checkbox or text input also triggers the browser's
  # implicit submission, which would pass these examples without the shortcut.
  def press_mod_enter_on_modal(modifier = :meta)
    page.execute_script("document.querySelector('.modal:popover-open').focus()")
    page.driver.browser.keyboard.type([modifier, :enter])
  end

  [[:meta, "Cmd"], [:control, "Ctrl"]].each do |modifier, label|
    it "runs the action once on #{label}+Return from a text field" do
      runs = count_dummy_action_runs
      open_dummy_action

      find_field("fields_persistent_text").send_keys([modifier, :enter])

      expect(page).to have_text("Success response", count: 1)
      expect(page).not_to have_selector("[role='dialog']")
      sleep 0.3
      expect(runs.call).to eq 1
    end
  end

  it "runs the action on Cmd+Return when focus is outside any field" do
    runs = count_dummy_action_runs
    open_dummy_action

    press_mod_enter_on_modal

    expect(page).to have_text("Success response", count: 1)
    sleep 0.3
    expect(runs.call).to eq 1
  end

  # @github/hotkey is installed on turbo:load and turbo:frame-render only, so a modal a stream
  # inserts never had the shortcut. Re-insert the action modal through a stream to reproduce that.
  it "runs the action from a modal inserted by a Turbo Stream" do
    runs = count_dummy_action_runs
    open_dummy_action

    html = page.evaluate_script("document.getElementById('modal_frame').innerHTML")
    page.execute_script("document.getElementById('modal_frame').innerHTML = ''")
    expect(page).not_to have_selector("[role='dialog']")

    page.execute_script(<<~JS, html)
      const stream = document.createElement("turbo-stream")
      stream.setAttribute("action", "update")
      stream.setAttribute("target", "modal_frame")
      const template = document.createElement("template")
      template.innerHTML = arguments[0]
      stream.appendChild(template)
      document.body.appendChild(stream)
    JS
    expect(page).to have_selector("[role='dialog']")

    press_mod_enter_on_modal

    expect(page).to have_text("Success response", count: 1)
    sleep 0.3
    expect(runs.call).to eq 1
  end

  it "leaves the modal alone when hotkeys are disabled" do
    Avo.configuration.hotkeys = {enabled: false, show_key_badges: false}
    runs = count_dummy_action_runs
    open_dummy_action

    press_mod_enter_on_modal

    sleep 0.5
    expect(page).to have_selector("[role='dialog']")
    expect(runs.call).to eq 0
  end

  it "saves the record in the belongs_to create modal, not the form behind it" do
    fish = create(:fish, user: create(:user))
    visit "/admin/resources/fish/#{fish.id}/edit"

    click_on "Create new user"

    within("turbo-frame#modal_frame") do
      fill_in "user_email", with: "#{SecureRandom.hex(12)}@gmail.com"
      fill_in "user_first_name", with: "FirstName"
      fill_in "user_last_name", with: "LastName"
      fill_in "user_password", with: "password"
      fill_in "user_password_confirmation", with: "password"
    end

    expect {
      find_field("user_first_name").send_keys([:meta, :enter])
      expect(page).not_to have_selector("[role='dialog']")
    }.to change(User, :count).by(1)

    expect(page).to have_select("fish_user_id", selected: User.last.name)
    expect(page).to have_current_path("/admin/resources/fish/#{fish.id}/edit", ignore_query: true)
  end
end
