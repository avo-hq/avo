require "rails_helper"

RSpec.describe "SelectAll", type: :system do
  let!(:per_page) { 2 }
  # Create per_page + 1 Spec Salmons because otherwise with exactly 1 page they're already all selected
  let!(:spec_salmon_number) { per_page + 1 }
  let!(:total_fish) { per_page + spec_salmon_number }
  let!(:info_string) { "records selected on this page from a total of" }
  let!(:random_fishes) { create_list :fish, per_page }
  let!(:salmon) { create_list :fish, spec_salmon_number, name: "Spec Salmon" }
  let!(:url) { "/admin/resources/fish?per_page=#{per_page}" }

  describe "without applyed filters" do
    context "select first page" do
      it "releases the fish from the selected page" do
        visit url

        check_select_all

        release_fish

        expect(page).to have_text "#{per_page} fish released with message '' by ."
      end
    end

    context "select all records" do
      it "releases all fishes" do
        visit url

        check_select_all
        expect_all_message

        click_on "Select all matching"
        expect_all_matching_message

        release_fish

        expect(page).to have_text "#{total_fish} fish released with message '' by ."
      end
    end

    context "press undo" do
      it "releases the fish from the selected page" do
        visit url

        check_select_all
        expect_all_message

        click_on "Select all matching"
        expect_all_matching_message

        click_on "Undo"
        expect_all_message

        release_fish

        expect(page).to have_text "#{per_page} fish released with message '' by ."
      end
    end

    context "uncheck one of them" do
      it "releases the fish from the selected page - 1" do
        visit url

        check_select_all
        expect_all_message

        click_on "Select all matching"
        expect_all_matching_message

        uncheck_first_record
        release_fish

        expect(page).to have_text "#{per_page - 1} fish released with message '' by ."
      end
    end
  end

  describe "with applyed filters" do
    context "select all" do
      it "releases all fish from applyed filter" do
        visit url

        open_filters_menu
        expect(page).to have_text "Name filter"
        fill_in "avo_filters_name_filter", with: "Spec Salmon"
        click_on "Filter by name"
        wait_for_loaded

        check_select_all
        expect(page).to have_text "#{per_page} records selected on this page from a total of #{spec_salmon_number}"

        click_on "Select all matching"

        expect(page).to have_text "#{spec_salmon_number} records selected from all pages"
        release_fish

        expect(page).to have_text "#{spec_salmon_number} fish released with message '' by ."
      end
    end

    describe "countless resource" do
      context "select all" do
        it "display contless messages" do
          pagination = FishResource.pagination
          FishResource.pagination = -> do
            {
              type: :countless
            }
          end

          visit url

          within('nav.pagy-nav.pagination') do
            expect(page).to have_css('span.page.active', text: '1')
            expect(page).to have_css('span.page', text: '2')
          end

          check_select_all
          expect(page).to have_text "2 records selected on this page"

          click_on "Select all matching"
          expect(page).to have_text "All records selected from all pages"

          FishResource.pagination = -> do
            {
              type: :countless,
              size: []
            }
          end

          visit url

          within('nav.pagy-nav.pagination') do
            expect(page).not_to have_css('span.page.active', text: '1')
            expect(page).not_to have_css('span.page', text: '2')
          end

          check_select_all
          expect(page).to have_text "2 records selected on this page"

          click_on "Select all matching"
          expect(page).to have_text "All records selected from all pages"

          FishResource.pagination = pagination
        end
      end
    end
  end
end

def check_select_all
  find(:css, 'input[type="checkbox"][data-action="input->item-select-all#toggle"]').set(true)
end

def uncheck_first_record
  find(:css, 'input[type="checkbox"][data-action="input->item-selector#toggle input->item-select-all#selectRow"]', match: :first).set(false)
  expect(page).not_to have_text info_string
end

def press_button_and_expect(button:, selected:, total:, string:)
  find('span', text: button).click
  # expect(page).to have_text selected_info_string(selected, total)
end

def release_fish
  click_on "Actions"
  click_on "Release fish"
  wait_for_loaded
  click_on "Run"
  wait_for_loaded
end

def expect_all_message
  expect(page).to have_text "#{per_page} records selected on this page from a total of #{total_fish}"
end

def expect_all_matching_message
  expect(page).to have_text "#{total_fish} records selected from all pages"
end

def selected_info_string(selected, number_of_fish)
  "#{selected} #{info_string} #{number_of_fish}"
end
