require "rails_helper"

RSpec.describe "CopyFieldContent", type: :system do
  let!(:user) { User.first }

  def test_copy_to_clipboard(path)
    visit path

    element = find('div[data-controller="clipboard"]', visible: :all)
    expect(element).to be_present
    element.hover

    copy_button = element.find('button[data-action="clipboard#copy"]', visible: :visible)
    copy_button.click
  end

  def test_button_visability(path)
    visit path

    element = find('div[data-controller="clipboard"]', visible: :all)
    expect(element).to be_present
  end

  describe "index view" do
    let(:path) { "/admin/resources/users" }

    it "shows copy to clipboard icon" do
      test_button_visability(path)
    end

    it "copies to clipboard after clicking button" do
      test_copy_to_clipboard(path)
    end
  end

  describe "show view" do
    let(:path) { "/admin/resources/users/#{user.id}" }

    it "shows copy to clipboard icon" do
      test_button_visability(path)
    end

    it "copies to clipboard after clicking button" do
      test_copy_to_clipboard(path)
    end
  end
end
