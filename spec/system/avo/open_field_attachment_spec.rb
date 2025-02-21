require "rails_helper"

RSpec.describe "OpenFieldAttachment", type: :system do
  let!(:user) { User.first }
  let(:path) { "/admin/resources/field_discovery_users/#{user.slug}" }

  def test_open_field_attachment(path)
    visit path

    element = find('svg[data-slot="icon"]')
    expect(element).to be_present
    element.click

    expect(page.driver.browser.current_url).not_to include("download")
    expect(page.driver.browser.window_handles.length).to eq 2
  end

  it "opens attachment in new window without download" do
    test_open_field_attachment(path)
  end
end
