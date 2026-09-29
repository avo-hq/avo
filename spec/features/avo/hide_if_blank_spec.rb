require "rails_helper"

RSpec.describe "hide_if_blank", type: :feature do
  # The blank post is newer, so it is the first row on the index.
  let!(:filled_post) { create :post, name: "Filled post", body: "Some body" }
  let!(:blank_post) { create :post, name: "Blank post", body: nil }

  after { Avo::Resources::Post.restore_items_from_backup }

  def body_field(**options)
    Avo::Resources::Post.with_temporary_items do
      field :id, as: :id
      field :body, as: :text, **options
      field :name, as: :text
    end
  end

  it "hides a blank field on index only when every row is blank" do
    body_field hide_if_blank: :index

    visit "/admin/resources/posts?view_type=table"
    expect(all("table thead th").map(&:text).reject(&:blank?)).to eq ["Select all", "ID", "Body", "Name"]

    filled_post.update!(body: nil)

    visit "/admin/resources/posts?view_type=table"
    expect(page).not_to have_css "table thead th", text: "Body"
  end

  it "hides a blank field on show and keeps a filled one" do
    body_field hide_if_blank: :show

    visit avo.resources_post_path(blank_post)
    expect(page).not_to have_css '[data-field-id="body"]'

    visit avo.resources_post_path(filled_post)
    expect(page).to have_css '[data-field-id="body"]', text: "Some body"

    visit avo.edit_resources_post_path(blank_post)
    expect(page).to have_field "post_body"
  end

  it "hides a blank field on edit, also after a failed update, and keeps a filled one" do
    body_field hide_if_blank: :edit

    visit avo.edit_resources_post_path(blank_post)
    expect(page).not_to have_field "post_body"

    fill_in "post_name", with: ""
    save
    expect(page).to have_text "can't be blank"
    expect(page).not_to have_field "post_body"

    visit avo.edit_resources_post_path(filled_post)
    expect(page).to have_field "post_body", with: "Some body"
  end

  it "hides a blank field on new unless a default fills it" do
    body_field hide_if_blank: :new

    visit avo.new_resources_post_path
    expect(page).not_to have_field "post_body"

    body_field hide_if_blank: :new, default: "Draft"

    visit avo.new_resources_post_path
    expect(page).to have_field "post_body", with: "Draft"
  end

  it "hides a blank field in every view with :all" do
    body_field hide_if_blank: :all

    visit "/admin/resources/posts?view_type=table"
    expect(page).to have_css "table thead th", text: "Body"

    visit avo.resources_post_path(blank_post)
    expect(page).not_to have_css '[data-field-id="body"]'
    visit avo.resources_post_path(filled_post)
    expect(page).to have_css '[data-field-id="body"]', text: "Some body"

    visit avo.edit_resources_post_path(blank_post)
    expect(page).not_to have_field "post_body"
    visit avo.edit_resources_post_path(filled_post)
    expect(page).to have_field "post_body", with: "Some body"

    visit avo.new_resources_post_path
    expect(page).not_to have_field "post_body"
  end
end
