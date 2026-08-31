require "rails_helper"

# The Save button wraps its label in a `.button__label` span, so clicking the word "Save" targets that span rather than
# the button. WebKit abandons a submit button's activation behaviour when its click target is removed mid-dispatch, so a
# loading state that rebuilds the button's contents silently kills the submit in Safari while Chrome and Firefox submit
# anyway (AVO-1751). Safari is not in CI, so the regression is pinned on the browser-agnostic invariant Safari depends
# on: the clicked element is still attached when the click finishes dispatching.
RSpec.describe "Loading button", type: :system do
  let(:project) { create :project }
  let(:store) { create :store, name: "original name" }

  # Only the Save button is rendered with `loading: true`, so this class picks it out without matching on label text.
  let(:save_button_selector) { "button.button--loading" }

  # Records whether the element the user actually clicked survived the dispatch. The listener sits on `document` in the
  # bubble phase, so it runs after the button's own handlers have had their chance to mutate the DOM.
  def install_click_target_probe
    page.execute_script(<<~JS)
      window.__avoClickProbe = null
      document.addEventListener('click', (event) => {
        window.__avoClickProbe = {
          className: String(event.target.className || ''),
          connected: event.target.isConnected
        }
      })
    JS
  end

  def click_target_probe
    page.evaluate_script("window.__avoClickProbe")
  end

  def save_button_box
    page.evaluate_script(<<~JS)
      (() => {
        const rect = document.querySelector('#{save_button_selector}').getBoundingClientRect()
        return {width: Math.round(rect.width), height: Math.round(rect.height)}
      })()
    JS
  end

  def save_label_visibility
    page.evaluate_script(<<~JS)
      getComputedStyle(document.querySelector('#{save_button_selector} .button__label')).visibility
    JS
  end

  def click_save_label
    find("#{save_button_selector} .button__label", text: "Save").click
  end

  # Saving a store asks for confirmation, so the click completes without navigating away and the loading state stays up.
  def visit_store_edit
    visit "/admin/resources/stores/#{store.id}/edit"
    expect(page).to have_field "store[name]"
  end

  def expect_confirmation_dialog
    expect(page).to have_selector "#turbo-confirm button[value='confirm']"
  end

  describe "clicking the button's inner elements" do
    it "leaves the clicked label attached for the whole click dispatch" do
      visit_store_edit
      install_click_target_probe

      click_save_label
      expect_confirmation_dialog

      probe = click_target_probe
      expect(probe["className"]).to include "button__label"
      expect(probe["connected"]).to be true
    end

    it "saves when the click lands on the label text" do
      visit "/admin/resources/projects/#{project.id}/edit"
      fill_in "project[name]", with: "Renamed from the label"

      click_save_label

      expect(page).to have_text "Project was successfully updated"
      expect(project.reload.name).to eq "Renamed from the label"
    end

    it "saves when the click lands on the keyboard shortcut badge" do
      visit "/admin/resources/projects/#{project.id}/edit"
      fill_in "project[name]", with: "Renamed from the badge"

      find("#{save_button_selector} .hotkey-badge").click

      expect(page).to have_text "Project was successfully updated"
      expect(project.reload.name).to eq "Renamed from the badge"
    end

    # The Mod+Enter path submits without a click target at all; avo_cmd_return_to_submits_spec.rb already covers it.
  end

  describe "loading state" do
    it "overlays a spinner and hides the label without resizing the button" do
      visit_store_edit
      idle_box = save_button_box

      click_save_label
      expect_confirmation_dialog

      expect(page).to have_selector "#{save_button_selector} .button__spinner"
      expect(page).to have_selector "#{save_button_selector}[aria-busy='true']"
      expect(save_label_visibility).to eq "hidden"
      expect(save_button_box).to eq idle_box
    end

    it "restores the button when the confirmation is dismissed" do
      visit_store_edit

      click_save_label
      expect_confirmation_dialog

      find("#turbo-confirm button", text: "No, cancel").click

      expect(page).not_to have_selector "#{save_button_selector} .button__spinner"
      expect(page).not_to have_selector "#{save_button_selector}[aria-busy='true']"
      expect(page).to have_selector "#{save_button_selector} .button__label", text: "Save"
      expect(find(save_button_selector)).not_to be_disabled
      expect(store.reload.name).to eq "original name"
    end

    it "does not stack a second spinner when the button is clicked again" do
      visit_store_edit

      click_save_label
      expect_confirmation_dialog
      find("#turbo-confirm button", text: "No, cancel").click
      expect(page).not_to have_selector "#{save_button_selector} .button__spinner"

      click_save_label
      expect_confirmation_dialog

      expect(page).to have_selector "#{save_button_selector} .button__spinner", count: 1
    end
  end
end
