require "rails_helper"

RSpec.describe "CopyFieldContent", type: :system do
  let!(:project) { create :project }

  def test_copy_to_clipboard(path)
    visit path
    element = find('div[data-controller="clipboard"]')
    element.hover
    find('button[data-action="clipboard#copy"]').click

    expect(page).to have_css('svg[class*="clipboard-document-check"]')

    sleep 2
    expect(page).to have_no_css('svg[class*="clipboard-document-check"]')
  end

  describe "index view" do
    let(:path) { "/admin/resources/projects" }

    it "shows copy to clipboard icon" do
      visit path

      element = find('div[data-controller="clipboard"]')
      element.hover

      expect(page).to have_css('svg[class*="clipboard"]')
    end

    it "copies to clipboard after clicking button" do
      test_copy_to_clipboard(path)
    end
  end

  describe "show view" do
    let(:path) { "/admin/resources/projects/#{project.id}" }

    it "shows copy to clipboard icon" do
      visit path

      element = find('div[data-controller="clipboard"]')
      element.hover

      expect(page).to have_css('svg[class*="clipboard"]')
    end

    it "copies to clipboard after clicking button" do
      test_copy_to_clipboard(path)
    end
  end
end
