require "rails_helper"

RSpec.describe "CopyFieldContent", type: :system do
  let!(:project) { create :project }

  # Metoda do sprawdzania kopiowania do schowka
  def test_copy_to_clipboard(path)
    visit path
    wait_for_loaded

    expect(page).to have_css("button[data-action='clipboard#copy']")

    button = find("button[data-action='clipboard#copy']")
    button.click

    expect(page).to have_css("div[data-clipboard-target='iconCopied']:not(.hidden)", wait: 3)
  end

  describe "index view" do
    let(:path) { "/admin/resources/projects" }

    it "shows copy to clipboard icon" do
      visit path
      wait_for_loaded

      expect(page).to have_css("svg[class*='clipboard']")
    end

    it "copies to clipboard after clicking button" do
      test_copy_to_clipboard(path)
    end
  end

  describe "show view" do
    let(:path) { "/admin/resources/projects/#{project.id}" }

    it "shows copy to clipboard icon" do
      visit path
      wait_for_loaded

      expect(page).to have_css("svg[class*='clipboard']")
    end

    it "copies to clipboard after clicking button" do
      test_copy_to_clipboard(path)
    end
  end
end
