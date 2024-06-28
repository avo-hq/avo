require 'rails_helper'

RSpec.describe "Alert Backtrace", type: :system do
  before do
    ENV['TEST_BACKTRACE_ALERT'] = '1'
  end

  it "responds with a backtrace alert" do
    visit "/admin/resources/courses/new"

    fill_in "Name", with: "Test"

    save

    expect(page).to have_text "raised"
    expect(page).to have_text "Backtrace:"
    expect(page).to have_text "/dummy/app/models/course.rb:25:in `block in <class:Course>'"
  end
end
