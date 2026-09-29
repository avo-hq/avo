require "rails_helper"

RSpec.describe "Unsaved changes warning", type: :system do
  let!(:team) { create :team, name: "Original name" }
  let(:edit_team_path) { "/admin/resources/teams/#{team.id}/edit" }
  let(:warning) { I18n.t("avo.unsaved_changes_warning") }

  around do |example|
    original = Avo.configuration.warn_on_unsaved_changes
    Avo.configuration.warn_on_unsaved_changes = true
    example.run
  ensure
    Avo.configuration.warn_on_unsaved_changes = original
  end

  # Cuprite clears the input before its first keydown, so click first like a user would.
  def change_team_name(to:)
    find_field("team_name").click
    fill_in "team_name", with: to
  end

  def dismiss_warning
    find('#turbo-confirm button[value="cancel"][data-confirm-dialog-target="option"]').click
  end

  it "leaves without asking when nothing changed" do
    visit edit_team_path
    find_field("team_name").click

    click_on "Cancel"

    expect(page).not_to have_current_path(edit_team_path)
    expect(page).not_to have_css("#turbo-confirm[open]")
  end

  it "asks before leaving with changes" do
    visit edit_team_path
    change_team_name to: "Changed name"

    click_on "Cancel"
    expect(page).to have_css("#turbo-confirm[open]", text: warning)
    dismiss_warning

    expect(page).to have_current_path(edit_team_path)
    expect(page).to have_field("team_name", with: "Changed name")

    accept_custom_alert { click_on "Cancel" }

    expect(page).not_to have_current_path(edit_team_path)
    expect(team.reload.name).to eq "Original name"
  end

  it "leaves without asking when the change was undone" do
    visit edit_team_path
    change_team_name to: "Changed name"
    change_team_name to: "Original name"

    click_on "Cancel"

    expect(page).not_to have_current_path(edit_team_path)
    expect(page).not_to have_css("#turbo-confirm[open]")
  end

  it "asks before going back in history" do
    visit "/admin/resources/teams/#{team.id}"
    click_on "Edit"
    expect(page).to have_current_path(edit_team_path, ignore_query: true)
    change_team_name to: "Changed name"

    page.go_back
    expect(page).to have_css("#turbo-confirm[open]", text: warning)
    dismiss_warning

    expect(page).to have_current_path(edit_team_path, ignore_query: true)
    expect(page).to have_field("team_name", with: "Changed name")

    accept_custom_alert { page.go_back }

    expect(page).to have_current_path("/admin/resources/teams/#{team.id}")
  end

  it "does not ask after saving" do
    visit edit_team_path
    change_team_name to: "Changed name"

    click_on "Save"

    expect(page).to have_current_path("/admin/resources/teams/#{team.id}")
    expect(page).not_to have_css("#turbo-confirm[open]")
    expect(team.reload.name).to eq "Changed name"
  end

  it "keeps asking after a save that failed validation" do
    visit edit_team_path
    change_team_name to: ""
    click_on "Save"
    expect(page).to have_text "can't be blank"

    click_on "Cancel"

    expect(page).to have_css("#turbo-confirm[open]", text: warning)
  end

  describe "a form with JS driven fields" do
    let!(:post) { create :post }
    let(:edit_post_path) { "/admin/resources/posts/#{post.to_param}/edit" }

    it "leaves without asking when the fields were only clicked" do
      visit edit_post_path
      find("trix-editor").click

      click_on "Cancel"

      expect(page).not_to have_current_path(edit_post_path)
      expect(page).not_to have_css("#turbo-confirm[open]")
    end

    it "asks after typing in a trix editor" do
      visit edit_post_path
      find("trix-editor").click.set("A new body")

      click_on "Cancel"

      expect(page).to have_css("#turbo-confirm[open]", text: warning)
    end

    %w[code_value easy_mde_content].each do |field_id|
      it "asks after typing in the #{field_id} editor" do
        playground = Playground.create!(name: "Editors")
        visit "/admin/resources/playgrounds/#{playground.id}/edit"

        within("[data-field-id='#{field_id}'] .CodeMirror") do
          current_scope.click
          type "Some text"
        end
        click_on "Cancel"

        expect(page).to have_css("#turbo-confirm[open]", text: warning)
      end
    end
  end

  describe "a form that shows an association" do
    let!(:user) { create :user, first_name: "Original" }
    let(:edit_user_path) { "/admin/resources/users/#{user.to_param}/edit" }

    before { create_list :post, 2, user: user }

    # The association loads in a lazy frame inside the form, and brings its own search and scope inputs.
    def open_posts_tab
      find("[data-action*='tabs#changeTab']", text: "Posts", match: :first).click
      expect(page).to have_css("turbo-frame#has_many_field_show_posts[complete] input[name='q']")
    end

    it "leaves without asking after the association loads" do
      visit edit_user_path
      find_field("user_first_name").click
      open_posts_tab

      click_on "Cancel"

      expect(page).not_to have_current_path(edit_user_path)
      expect(page).not_to have_css("#turbo-confirm[open]")
    end

    it "leaves without asking after searching the association" do
      visit edit_user_path
      find_field("user_first_name").click
      open_posts_tab

      within("turbo-frame#has_many_field_show_posts") do
        find("input[name='q']").click
        type "anything"
      end
      click_on "Cancel"

      expect(page).not_to have_current_path(edit_user_path)
      expect(page).not_to have_css("#turbo-confirm[open]")
    end

    it "still asks when a field of the record changed" do
      visit edit_user_path
      find_field("user_first_name").click
      open_posts_tab
      fill_in "user_first_name", with: "Changed"

      click_on "Cancel"

      expect(page).to have_css("#turbo-confirm[open]", text: warning)
    end

    it "still asks when a field inside a tab changed" do
      visit edit_user_path
      find_field("user_first_name").click
      open_posts_tab
      find("[data-action*='tabs#changeTab']", text: "Birthday", match: :first).click

      find("[data-field-id='birthday'] input[type='text']").click
      find(".flatpickr-calendar.open .flatpickr-day:not(.selected):not(.prevMonthDay):not(.nextMonthDay)", match: :first).click
      click_on "Cancel"

      expect(page).to have_css("#turbo-confirm[open]", text: warning)
    end
  end

  it "stays on the form when the warning is closed by clicking outside of it, after an earlier confirmation" do
    post = create :post, name: "Original name"
    post.cover.attach(io: Rails.root.join("db", "seed_files", "dummy-image.jpg").open, filename: "dummy-image.jpg")
    edit_post_path = "/admin/resources/posts/#{post.to_param}/edit"
    visit edit_post_path

    # Deleting the file answers the same dialog with a confirmation and keeps the page.
    accept_custom_alert { find("[data-field-id='cover'] a[data-turbo-method='delete']").click }
    expect(page).not_to have_css("[data-field-id='cover'] a[data-turbo-method='delete']")

    find_field("post_name").click
    fill_in "post_name", with: "Changed name"
    click_on "Cancel"
    expect(page).to have_css("#turbo-confirm[open]", text: warning)

    page.driver.browser.mouse.click(x: 5, y: 5)
    expect(page).not_to have_css("#turbo-confirm[open]")
    page.driver.wait_for_network_idle

    expect(page).to have_current_path(edit_post_path)
    expect(page).to have_field("post_name", with: "Changed name")
  end

  it "does not ask when the form is saved without Turbo" do
    visit edit_team_path
    page.execute_script("document.querySelector('form[data-controller~=\"unsaved-changes\"]').dataset.turbo = 'false'")
    change_team_name to: "Changed name"

    # The browser's own prompt would show up as a modal.
    expect { accept_confirm(wait: 1) { click_on "Save" } }.to raise_error(Capybara::ModalNotFound)

    expect(page).to have_current_path("/admin/resources/teams/#{team.id}")
    expect(team.reload.name).to eq "Changed name"
  end

  it "shows the saved values when coming back to a form whose changes were discarded" do
    visit "/admin/resources/teams/#{team.id}"
    click_on "Edit"
    expect(page).to have_current_path(edit_team_path, ignore_query: true)
    change_team_name to: "Changed name"
    accept_custom_alert { click_on "Cancel" }
    expect(page).to have_current_path("/admin/resources/teams/#{team.id}")

    page.go_back

    expect(page).to have_current_path(edit_team_path, ignore_query: true)
    expect(page).to have_field("team_name", with: "Original name")
  end

  it "does not ask when the option is off" do
    Avo.configuration.warn_on_unsaved_changes = false
    visit edit_team_path
    change_team_name to: "Changed name"

    click_on "Cancel"

    expect(page).not_to have_current_path(edit_team_path)
    expect(page).not_to have_css("#turbo-confirm[open]")
  end
end
