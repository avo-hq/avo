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
        expect(page).to have_button "Runnables"
        expect(page).to have_link "Dummy action", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=Sub::DummyAction/, visible: false

        # action link
        expect(page).to have_link "Release fish", href: /\/admin\/resources\/fish\/#{fish.id}\/actions\?action_id=ReleaseFish/
        expect(page).to have_selector 'a[data-turbo-frame="actions_show"][data-action="click->actions-picker#visitAction"]', text: "Release fish"

        # edit button
        expect(page).to have_link "", href: /\/admin\/resources\/fish\/#{fish.id}\/edit/
      end
    end
  end
end
