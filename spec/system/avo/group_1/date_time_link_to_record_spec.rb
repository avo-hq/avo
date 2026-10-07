require "rails_helper"

RSpec.describe "Date field with link_to_record", type: :system do
  let!(:comment) { create :comment, posted_at: Time.new(1988, 2, 10, 16, 22, 0, "UTC") }

  before do
    Avo::Resources::Comment.with_temporary_items do
      field :body, as: :textarea
      field :posted_at,
        as: :date_time,
        link_to_record: true,
        relative: false,
        format: "cccc, d LLLL yyyy, HH:mm ZZZZ"
    end
  end

  after do
    Avo::Resources::Comment.restore_items_from_backup
  end

  it "keeps the formatted date and links it to the record" do
    visit "/admin/resources/comments"

    click_link "Wednesday, 10 February 1988, 16:22 UTC"

    expect(page).to have_current_path avo.resources_comment_path(comment)
  end
end
