require "rails_helper"

RSpec.describe "OpenFieldAttachment", type: :system do
  let!(:user) { User.first }
  let!(:cv_file) { Rails.root.join('app', 'assets', 'pdfs', 'cv_sample.pdf') }
  let(:path) { "/admin/resources/field_discovery_users/#{user.slug}" }

  before do
    user.cv.attach(io: File.open(cv_file), filename: 'cv_sample.pdf', content_type: 'application/pdf')
  end

  def test_open_field_attachment(path)
    visit path

    link = find('a[rel="noopener noreferrer"][target="_blank"]', visible: :all)
    expect(link).to be_present
    link.click

    expect(page.driver.browser.current_url).not_to include("download")
    expect(page.driver.browser.window_handles.length).to eq 2
  end

  it "opens attachment in new window without download" do
    test_open_field_attachment(path)
  end
end
