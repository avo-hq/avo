require "rails_helper"

RSpec.describe "Table row navigation", type: :system do
  let!(:fish) { create :fish, name: "Selectable fish name" }
  let(:name_cell) { find("tr[data-record-id='#{fish.to_param}'] td[data-field-id='name']") }

  before do
    visit "/admin/resources/fish"
    expect(page).to have_text fish.name
  end

  it "opens the record on the first click even if the pointer moves slightly" do
    # Move within the cell's padding, so no text is selected.
    x, y = name_cell.evaluate_script("[this.getBoundingClientRect().x + 2, this.getBoundingClientRect().y + 2]")
    mouse = page.driver.browser.mouse
    mouse.move(x: x, y: y)
    mouse.down
    mouse.move(x: x + 2, y: y)
    mouse.up

    expect(page).to have_current_path "/admin/resources/fish/#{fish.to_param}"
  end

  it "allows selecting text without opening the record" do
    name_cell.execute_script(<<~JS)
      const range = document.createRange()
      range.selectNodeContents(this)
      window.getSelection().removeAllRanges()
      window.getSelection().addRange(range)
      this.dispatchEvent(new MouseEvent('click', {bubbles: true}))
    JS

    expect(page).to have_current_path "/admin/resources/fish"
    expect(page.evaluate_script("window.getSelection().toString()")).to include fish.name
  end

  it "opens a middle-clicked row in a new tab without navigating the index" do
    x, y = name_cell.evaluate_script("[this.getBoundingClientRect().x + 2, this.getBoundingClientRect().y + 2]")
    tab = window_opened_by { page.driver.browser.mouse.click(x: x, y: y, button: :middle) }

    within_window(tab) do
      expect(page).to have_current_path "/admin/resources/fish/#{fish.to_param}"
      expect(page.evaluate_script("window.opener")).to be_nil
    end

    expect(page).to have_current_path "/admin/resources/fish"
  ensure
    tab&.close
  end
end
