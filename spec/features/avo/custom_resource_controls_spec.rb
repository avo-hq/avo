require "rails_helper"

RSpec.feature "CustomResourceControls", type: :feature do
  let!(:fish) { create :fish }

  describe ".show" do
    it "renders the custom buttons" do
      visit "/admin/resources/fish/#{fish.id}"

      within find_all('[data-target="panel-tools"]').first do
        # back_button
        expect(page).to have_link "", href: /\/admin\/resources\/fish/

        # link_to
        expect(page).to have_link "Fish.com", href: "https://fish.com"

        # link_to with data attributes
        expect(page).to have_link "Turbo demo", href: /\/admin\/resources\/fish\/#{fish.id}/

        # actions_list
        expect(page).to have_button "Runnables with exclude"
        expect(page).to have_button "Runnables with include"
        expect(page).to have_button "Runnables"

        within find_all("[data-controller='toggle-panel actions-picker']").first do
          expect(page).not_to have_link "Release fish", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=ReleaseFish/
          expect(page).not_to have_selector 'a[data-turbo-frame="actions_show"][data-action="click->actions-picker#visitAction"]', text: "Release fish"

          expect(page).to have_link "Dummy action", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=Sub::DummyAction/, visible: false

          expect(page).to have_link "Export csv", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=ExportCsv/
          expect(page).to have_selector 'a[data-turbo-frame="actions_show"][data-action="click->actions-picker#visitAction"]', text: "Export csv"

          expect(page).to have_link "Download file", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=DownloadFile/
          expect(page).to have_selector 'a[data-turbo-frame="actions_show"][data-action="click->actions-picker#visitAction"]', text: "Download file"
        end

        within find_all("[data-controller='toggle-panel actions-picker']")[1] do
          expect(page).not_to have_link "Release fish", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=ReleaseFish/
          expect(page).not_to have_selector 'a[data-turbo-frame="actions_show"][data-action="click->actions-picker#visitAction"]', text: "Release fish"

          expect(page).not_to have_link "Dummy action", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=Sub::DummyAction/, visible: false

          expect(page).to have_link "Export csv", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=ExportCsv/
          expect(page).to have_selector 'a[data-turbo-frame="actions_show"][data-action="click->actions-picker#visitAction"]', text: "Export csv"

          expect(page).to have_link "Download file", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=DownloadFile/
          expect(page).to have_selector 'a[data-turbo-frame="actions_show"][data-action="click->actions-picker#visitAction"]', text: "Download file"
        end

        within find_all("[data-controller='toggle-panel actions-picker']")[2] do
          expect(page).to have_link "Release fish", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=ReleaseFish/
          expect(page).to have_selector 'a[data-turbo-frame="actions_show"][data-action="click->actions-picker#visitAction"]', text: "Release fish"

          expect(page).to have_link "Dummy action", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=Sub::DummyAction/, visible: false

          expect(page).to have_link "Export csv", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=ExportCsv/
          expect(page).to have_selector 'a[data-turbo-frame="actions_show"][data-action="click->actions-picker#visitAction"]', text: "Export csv"

          expect(page).to have_link "Download file", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=DownloadFile/
          expect(page).to have_selector 'a[data-turbo-frame="actions_show"][data-action="click->actions-picker#visitAction"]', text: "Download file"
        end

        # action link
        expect(page).to have_link "Release fish", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=ReleaseFish/
        expect(page).to have_selector 'a[data-turbo-frame="actions_show"][data-action="click->actions-picker#visitAction"]', text: "Release fish"
        expect(page).to have_link "Dummy action", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=Sub::DummyAction/, visible: false

        # edit button
        expect(page).to have_link "", href: /\/admin\/resources\/fish\/#{fish.id}\/edit/
      end
    end
  end
end
