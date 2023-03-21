require "rails_helper"

RSpec.feature "Search with custom path", type: :system do
  let(:url) { "/admin/resources/cities" }

  subject do
    visit url
    page
  end

  describe "global search" do
    let!(:city) { create :city, name: "São Paulo" }

    context "when search result path has been changed" do
      it "can find the city" do
        visit url
        open_global_search_box
        expect_search_panel_open

        write_in_search "São Paulo"
        expect(page).to have_content "São Paulo"
        find(".aa-Panel").find(".aa-Item div", text: "São Paulo", match: :first).click
        sleep 0.8

        expect(page.current_url).to include("custom=yup")
      end
    end
  end
end

def open_global_search_box
  find(".global-search").click
end

def expect_search_panel_open
  expect(page).to have_css ".aa-InputWrapper .aa-Input"
  expect(page).to have_selector(".aa-Input:focus")
end
