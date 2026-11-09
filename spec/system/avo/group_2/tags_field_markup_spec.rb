require "rails_helper"

RSpec.describe "Tags field markup", type: :system do
  let(:payload) { %(<img src="data:image/png;base64,x" onerror="window.tagPayloadRan = true">) }
  let!(:post) { create :post, tag_list: [] }

  def open_field
    visit "/admin/resources/posts/#{post.to_param}/edit"
    find(".tagify__input", match: :first, visible: :all).click
    # The image's error event fires a moment after Tagify parses the markup, so an immediate read proves nothing.
    sleep 0.5
  end

  def expect_payload_not_to_run
    expect(page.evaluate_script("window.tagPayloadRan")).to be_nil
  end

  it "shows a suggestion's markup as text in the dropdown and in the tag" do
    allow(Post).to receive(:tags_suggestions).and_return([{value: "one", label: payload}])
    post.update!(tag_list: ["one"])

    open_field

    expect_payload_not_to_run
    expect(page).to have_css("tag .tagify__tag-text", exact_text: payload)
  end

  it "shows a stored tag as text, with its special characters once" do
    markup = %(<img src onerror="window.tagPayloadRan = true">)
    allow(Post).to receive(:tags_suggestions).and_return([{value: "one", label: "One"}])
    post.update!(tag_list: ["R&D", markup])

    open_field

    expect_payload_not_to_run
    expect(page).to have_css("tag .tagify__tag-text", exact_text: "R&D")
    expect(page).to have_css("tag .tagify__tag-text", exact_text: markup)
  end

  it "keeps a suggestion's avatar inside its src attribute" do
    avatar = %(data:,x"><img src="data:image/png;base64,x" onerror="window.tagPayloadRan = true">)
    allow(Post).to receive(:tags_suggestions).and_return([{value: "one", label: "One", avatar:}])

    open_field

    expect(page).to have_css(".tagify__dropdown__item", text: "One")
    expect_payload_not_to_run
  end
end
