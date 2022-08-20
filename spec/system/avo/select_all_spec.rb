require "rails_helper"

RSpec.describe "SelectAll", type: :system do
  let!(:per_page) { Avo.configuration.per_page }
  let!(:total_fish) { 300 }
  let!(:info_string) { "selected from a total of" }
  let!(:fishes) { create_list :fish, total_fish }
  let!(:url) { "/admin/resources/fish" }

  describe "without applyed filters" do
    context "select first page" do
      it "releases the fish from the selected page" do
        visit url

        check_select_all_on_page_and_expect(selected: per_page, total: total_fish)
        release_fish

        expect(page).to have_text "#{per_page} fish released..."
      end
    end

    context "select all records" do
      it "releases all fishes" do
        visit url

        check_select_all_on_page_and_expect(
          selected: per_page,
          total: total_fish
        )

        press_button_and_expect(
          button: "Select all",
          selected: total_fish,
          total: total_fish
        )

        release_fish

        expect(page).to have_text "#{total_fish} fish released..."
      end

      context "press undo" do
        it "releases the fish from the selected page" do
          visit url

          check_select_all_on_page_and_expect(
            selected: per_page,
            total: total_fish
          )

          press_button_and_expect(
            button: "Select all",
            selected: total_fish,
            total: total_fish
          )

          press_button_and_expect(
            button: "Undo",
            selected: per_page,
            total: total_fish
          )

          release_fish

          expect(page).to have_text "#{per_page} fish released..."
        end
      end

      context "uncheck one of them" do
        it "releases the fish from the selected page - 1" do
          visit url

          check_select_all_on_page_and_expect(
            selected: per_page,
            total: total_fish
          )

          press_button_and_expect(
            button: "Select all",
            selected: total_fish,
            total: total_fish
          )

          uncheck_first_record
          release_fish

          expect(page).to have_text "#{per_page - 1} fish released..."
        end
      end
    end

    describe "with applyed filters" do
      context "select all" do
        it "releases all fish from applyed filter" do
          visit url

          open_filters_menu
          expect(page).to have_text "Name filter"
          filtered_fish_count, name = find_more_than_one_page_of_fish_with_the_same_name
          fill_in "avo_filters_name_filter", with: name
          click_on "Filter by name"
          wait_for_loaded

          check_select_all_on_page_and_expect(
            selected: per_page,
            total: filtered_fish_count
          )

          press_button_and_expect(
            button: "Select all",
            selected: filtered_fish_count,
            total: filtered_fish_count
          )

          expect(page).to have_text selected_info_string(filtered_fish_count, filtered_fish_count)
          release_fish

          expect(page).to have_text "#{filtered_fish_count} fish released..."
        end
      end
    end

  end
end

def check_select_all_on_page_and_expect(selected:,total:)
  find(:css, 'input[type="checkbox"][data-action="input->item-select-all#toggle"]').set(true)
  expect(page).to have_text selected_info_string(selected,total)
end

def uncheck_first_record
  find(:css, 'input[type="checkbox"][data-action="input->item-selector#toggle input->item-select-all#selectRow"]', match: :first).set(false)
  expect(page).not_to have_text info_string
end

def press_button_and_expect(button:,selected:,total:)
  find('span', text: button).click
  expect(page).to have_text selected_info_string(selected,total)
end

def release_fish
  click_on "Actions"
  click_on "Release fish"
  wait_for_loaded
  click_on "Run"
  wait_for_loaded
end

def selected_info_string(selected, number_of_fish)
  "#{selected} #{info_string} #{number_of_fish}"
end

def find_more_than_one_page_of_fish_with_the_same_name
  loop do
    Fish.find_each do |fish|
      count = Fish.where(name: fish.name).count
      return [count, fish.name] if count > per_page
    end
    raise "Did not found more than one page of fishes with the same name"
  end
end
