require "rails_helper"

RSpec.describe "EasyMDE preview", type: :system do
  let!(:playground) do
    Playground.create!(
      name: "Markdown from an end user",
      easy_mde_content: "Hi <img src=\"data:,\" onerror=\"window.easyMdeXss = true\">"
    )
  end

  it "does not run HTML handlers stored in the markdown" do
    visit "/admin/resources/playgrounds/#{playground.id}/edit"

    within("[data-field-id='easy_mde_content']") do
      find(".editor-toolbar button.preview", wait: 10).click

      expect(page).to have_css(".editor-preview img", visible: :all)
      expect(page).not_to have_css(".editor-preview img[onerror]", visible: :all)
    end

    expect(page.evaluate_script("window.easyMdeXss")).to be_nil
  end
end
