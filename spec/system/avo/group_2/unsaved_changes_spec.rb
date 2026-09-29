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

  it "does not ask when the option is off" do
    Avo.configuration.warn_on_unsaved_changes = false
    visit edit_team_path
    change_team_name to: "Changed name"

    click_on "Cancel"

    expect(page).not_to have_current_path(edit_team_path)
    expect(page).not_to have_css("#turbo-confirm[open]")
  end
end
