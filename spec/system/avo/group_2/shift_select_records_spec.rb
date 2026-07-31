require "rails_helper"

RSpec.describe "ShiftSelectRecords", type: :system do
  describe "on an index table" do
    let!(:fishes) { create_list :fish, 5 }

    before do
      visit "/admin/resources/fish"

      expect(page).to have_selector record_selector_checkbox_selector, count: fishes.size
    end

    it "selects every row between the two clicks when shift is held" do
      row_checkbox(1).click
      row_checkbox(4).click(:shift)

      expect(checked_row_indexes).to eq [1, 2, 3, 4]
    end

    it "selects the range when shift-clicking upwards" do
      row_checkbox(4).click
      row_checkbox(1).click(:shift)

      expect(checked_row_indexes).to eq [1, 2, 3, 4]
    end

    it "selects the range when it starts on the first row" do
      row_checkbox(0).click
      row_checkbox(2).click(:shift)

      expect(checked_row_indexes).to eq [0, 1, 2]
    end

    it "previews the range on hover when it starts on the first row" do
      row_checkbox(0).click
      find("#{row_selector(3)} .item-selector-cell").hover

      expect(page).to have_css "#{row_selector(1)}.highlighted-row"
      expect(page).to have_css "#{row_selector(2)}.highlighted-row"
    end

    it "checks only the clicked row when shift is not held" do
      row_checkbox(1).click
      row_checkbox(4).click

      expect(checked_row_indexes).to eq [1, 4]
    end
  end

  # A show page renders one table per has_many association, and every table numbers its rows from
  # zero, so an index only identifies a row within its own table.
  describe "with more than one table on the page" do
    let!(:person) { create :person }
    let!(:spouses) { create_list :spouse, 4, person: person }

    before do
      visit "/admin/resources/people/#{person.id}"

      expect(page).to have_selector shift_selectable_checkbox_selector, minimum: spouses.size * 2
    end

    it "selects the range inside the table that was clicked" do
      in_table(1) do
        row_checkbox(0).click
        row_checkbox(2).click(:shift)

        expect(checked_row_indexes).to eq [0, 1, 2]
      end

      in_table(0) do
        expect(checked_row_indexes).to be_empty
      end
    end

    it "previews the range inside the table that is hovered" do
      in_table(1) do
        row_checkbox(0).click
        find("#{row_selector(2)} .item-selector-cell").hover

        expect(page).to have_css "#{row_selector(1)}.highlighted-row"
      end

      in_table(0) do
        expect(page).not_to have_css "tr.highlighted-row"
      end
    end
  end
end

# The tables on a page, in render order. Each one is the element a record-selector controller is
# mounted on.
def in_table(position, &block)
  within all("[data-controller~='record-selector']")[position], &block
end

def row_selector(index)
  %(tr[data-index="#{index}"])
end

def row_checkbox(index)
  find(%(#{record_selector_checkbox_selector}[data-index="#{index}"]))
end

def checked_row_indexes
  all(record_selector_checkbox_selector).select(&:checked?).map { |checkbox| checkbox[:"data-index"].to_i }.sort
end
