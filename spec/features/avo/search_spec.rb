require "rails_helper"

RSpec.feature "Search", type: :system do
  let(:url) { "/admin/resources/users" }

  subject do
    visit url
    page
  end

  describe "global" do
    context "when doing ctrl+k" do
      it "opens the search" do
        visit url

        find('body').send_keys [:control, 'k']

        expect_search_panel_open
      end
    end

    context "when clicking the search box" do
      it "opens the search" do
        visit url

        find('.global-search').click

        expect_search_panel_open
      end
    end

    context "without results" do
      it "opens the search" do
        visit url
        open_global_search_box
        expect_search_panel_open

        write_in_search "wwwww"

        expect(page).to have_content 'No posts found'
        expect(page).to have_content 'No users found'
        expect(page).to have_content 'No projects found'
      end
    end

    context "with results" do
      let!(:post) { create :post, name: "New hehe post", body: 'New hehe post description.'}
      let!(:user) { create :user, first_name: "Hehe", last_name: "user", roles: {admin: true, manager: true, writer: true}}

      it "opens the search" do
        visit url
        open_global_search_box
        expect_search_panel_open

        write_in_search "hehe"

        expect(page).not_to have_content "No posts found"
        expect(page).not_to have_content "No users found"
        expect(page).to have_content "New hehe post"
        expect(page).to have_content "New hehe post description."
        expect(page).to have_content "Hehe user"
        expect(page).to have_content "This user has the following roles: admin, manager, writer"
      end

      it "goes to the search result" do
        visit url
        open_global_search_box
        expect_search_panel_open

        write_in_search "hehe"

        expect(page).to have_content "Hehe user"
        expect(page).to have_content "This user has the following roles: admin, manager, writer"

        find('.aa-Input').send_keys :arrow_down
        find('.aa-Input').send_keys :return

        sleep 0.2

        expect(current_path).to eql "/admin/resources/users/#{user.id}"
      end
    end
  end
end

def write_in_search(input)
  find('input.aa-Input').set(input)
end

def open_global_search_box
  find('.global-search').click
end

def expect_search_panel_open
  expect(page).to have_css ".aa-InputWrapper .aa-Input"
  expect(page).to have_selector('.aa-Input:focus')
end
