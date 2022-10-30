require "rails_helper"

RSpec.describe "TabsPanelsAndSidebarVisibility", type: :feature do
  describe "tabs" do
    let!(:visible_fields_spouse) { create :spouse, name: "RSpec TabsPanelAndSidebarVisibility" }
    let(:url_with_visible_fields_first_tab) {
      "/admin/resources/spouses/#{visible_fields_spouse.id}?active_tab_name=Hidden+field+inside+tabs&tab_turbo_frame=avo-tabgroup-2"
    }
    let(:url_with_visible_fields_second_tab) {
      "/admin/resources/spouses/#{visible_fields_spouse.id}?active_tab_name=Hidden+tab+inside+tabs&tab_turbo_frame=avo-tabgroup-2"
    }

    let!(:not_visible_fields_spouse) { create :spouse }
    let(:url_with_not_visible_fields) { "/admin/resources/spouses/#{not_visible_fields_spouse.id}" }

    context "none hidden" do
      it "find all tabs and fields" do
        visit url_with_visible_fields_first_tab
        expect(page).to have_text 'Hidden field inside tabs'
        expect(page).to have_text 'Hidden field inside sidebar'

        visit url_with_visible_fields_second_tab
        expect(page).to have_text 'Hidden field inside tabs inside tab'
        expect(page).to have_text 'Hidden field inside tabs inside tab inside panel'
        expect(page).to have_text 'Hidden field inside sidebar'
      end
    end

    context "all hidden" do
      it "don't find any tabs and fields" do
        visit url_with_not_visible_fields
        expect(page).not_to have_text 'Hidden field inside tabs'
        expect(page).not_to have_text 'Hidden field inside sidebar'
        expect(page).not_to have_text 'Hidden field inside tabs inside tab'
        expect(page).not_to have_text 'Hidden field inside tabs inside tab inside panel'
        expect(page).not_to have_text 'Hidden field inside sidebar'
      end
    end

  end
end
