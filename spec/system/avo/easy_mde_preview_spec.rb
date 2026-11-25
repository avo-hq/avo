require "rails_helper"

RSpec.describe "EasyMDE preview", type: :system do
  let!(:project) { create :project, description: "Hi <img src=\"data:,\" onerror=\"window.easyMdeXss = true\">" }

  it "does not run HTML handlers stored in the markdown" do
    visit "/admin/resources/projects/#{project.id}/edit"

    within("[data-field-id='description']") do
      find(".editor-toolbar button.preview", wait: 10).click

      expect(page).to have_css(".editor-preview img", visible: :all)
      expect(page).not_to have_css(".editor-preview img[onerror]", visible: :all)
    end

    expect(page.evaluate_script("window.easyMdeXss")).to be_nil
  end
end
