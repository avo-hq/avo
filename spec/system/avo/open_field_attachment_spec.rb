require "rails_helper"
include ActionView::RecordIdentifier

RSpec.describe "OpenFieldAttachment", type: :system do
  let!(:user) { create :user }

  context "with PDF attachment" do
    it "opens attachment in new window without download" do
      user.cv.attach(
        io: File.open(Rails.root.join("db", "seed_files", "dummy-file.pdf")),
        filename: "dummy-file.pdf",
        content_type: "application/pdf"
      )

      visit avo.resources_field_discovery_user_path(user)

      file_path = Rails.application.routes.url_helpers.rails_blob_path(user.cv, only_path: true)

      within("##{dom_id(user.cv)}") do
        link = find(:css, "a[href*='#{file_path}']:not([download])")
        expect(link[:target]).to eq("_blank")
        expect(link[:rel]).to eq("noopener noreferrer")

        new_window = window_opened_by { link.click }
        expect(new_window).not_to be_nil

        within_window new_window do
          # Check that final URL ends with filename, since path changes after redirect
          expect(page.current_url).to match(/dummy-file\.pdf\z/)
        end
      end
    end
  end

  context "with CSV attachment" do
    it "can not open or download attachment in new window" do
      csv_file_path = Rails.root.join("db", "seed_files", "sample.csv")

      user.cv.attach(
        io: File.open(csv_file_path),
        filename: "sample.csv",
        content_type: "application/csv"
      )

      visit avo.resources_field_discovery_user_path(user)

      file_path = Rails.application.routes.url_helpers.rails_blob_path(user.cv, only_path: true)

      within("##{dom_id(user.cv)}") do
        expect(page).not_to have_selector(:css, "a[href*='#{file_path}']:not([download])")
        expect(page).to have_selector(:css, "a[href*='#{file_path}'][download]")
      end
    end
  end
end
