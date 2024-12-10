require "rails_helper"

RSpec.describe "CopyFieldContent", type: :system do
  let!(:project) { create :project }

  def test_copy_to_clipboard(path)
    visit path
    element = all('div[data-controller="clipboard"]', visible: :all).first
    expect(element).to be_present
    element.hover
    element.find('button[data-action="clipboard#copy"]', visible: :all).click

    expect(element).to have_css('svg[class*="clipboard-document-check"]', visible: :all, wait: 2)
  end

  def test_button_visability(path)
    visit path

    element = all('div[data-controller="clipboard"]', visible: :all).first
    expect(element).to be_present
  end

  describe "index view" do
    let(:path) { "/admin/resources/projects" }

    it "shows copy to clipboard icon" do
      test_button_visability(path)
    end

    it "copies to clipboard after clicking button" do
      test_copy_to_clipboard(path)
    end
  end

  describe "show view" do
    let(:path) { "/admin/resources/projects/#{project.id}" }

    it "shows copy to clipboard icon" do
      test_button_visability(path)
    end

    it "copies to clipboard after clicking button" do
      test_copy_to_clipboard(path)
    end
  end
end
