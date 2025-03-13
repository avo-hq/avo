require "rails_helper"

RSpec.describe "OpenFieldAttachment", type: :system do
  let!(:user) { User.first }
  let!(:cv_file) { Rails.root.join("app", "assets", "pdfs", "cv_sample.pdf") }
  let!(:csv_file) { Rails.root.join("app", "assets", "csvs", "sample.csv") }
  let(:path) { "/admin/resources/field_discovery_users/#{user.slug}" }

  context "with PDF attachment" do
    before do
      user.cv.attach(io: File.open(cv_file), filename: "cv_sample.pdf", content_type: "application/pdf")
    end

    it "opens attachment in new window without download" do
      test_open_PDF_attachment(path)
    end
  end

  context "with CSV attachment" do
    before do
      user.cv.attach(io: File.open(csv_file), filename: "sample.csv", content_type: "application/csv")
    end

    it "can not open or download attachment in new window" do
      test_open_CSV_attachment(path)
    end
  end

  def test_open_PDF_attachment(path)
    visit path

    link = find('a[rel="noopener noreferrer"][target="_blank"]', visible: :all)
    expect(link).to be_present
    link.click

    expect(page.driver.browser.current_url).not_to include("download")
    expect(page.driver.browser.window_handles.length).to eq 2
  end

  def test_open_CSV_attachment(path)
    visit path

    link = first('a.relative', visible: :all)

    expect(link).to be_present
    expect(link[:target]).to eq("")
    expect(link[:rel]).to eq("")

    expect(page.driver.browser.current_url).not_to include("download")
    expect(page.driver.browser.window_handles.length).to eq 1
  end
end
