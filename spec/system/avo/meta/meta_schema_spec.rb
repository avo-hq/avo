require "rails_helper"

RSpec.describe "MetaSchema", type: :system do
  include ActiveJob::TestHelper

  let!(:user) { create :user }
  let!(:post) { create :post }
  let!(:schema) { create :meta_schema }

  it "allows to add new entries to the user meta schema" do
    visit "/admin/resources/meta_schemas"

    click_on "User"
  end

  it "allows to create completely new meta schemas" do
    visit avo.resources_post_path(Post.first)

    expect(page).not_to have_text("GUEST AUTHOR NAME")

    visit avo.resources_meta_schemas_path

    click_on "Create new meta schema"

    select "Post", from: "avo/meta/schema[resource_name]"

    click_on "Add a new property"

    fill_in "Name", with: "guest_author_name"
    select "Text", from: find('select[name*="[schema_entries_attributes]["][name*="][as]"]')[:id]

    save

    visit avo.resources_post_path(Post.first)

    expect(page).to have_text("GUEST AUTHOR NAME")
  end

  it "allows to add new entries to the user meta schema, which can instantly be used" do
    visit avo.edit_resources_meta_schema_path(schema)

    click_on "Add a new property"

    fill_in "Name", with: "nickname"
    select "Text", from: find('select[name*="[schema_entries_attributes]["][name*="][as]"]')[:id]

    save

    expect(page).to have_text("Meta schema was successfully updated")

    # assert that the new attribute is actually present and editable
    visit avo.resources_user_path(User.last)

    expect(page).to have_text("Meta")
    expect(page).to have_text("NICKNAME")

    click_on "Edit"

    fill_in "user_meta_nickname", with: "Ace Ventura"

    save

    expect(page).to have_text("Ace Ventura")
  end

  it "allows to add new entries to the user meta schema with default" do
    visit avo.edit_resources_meta_schema_path(schema)

    click_on "Add a new property"

    fill_in "Name", with: "driving_license"
    select "Text", from: find('select[name*="[schema_entries_attributes]["][name*="][as]"]')[:id]
    fill_in "Default", with: "B"

    save

    expect(page).to have_text("Meta schema was successfully updated")

    # assert that the new attribute is actually present and the default is prefilled
    visit avo.new_resources_user_path

    expect(page).to have_field("Driving license", with: "B")
  end

  it "ensures that existing meta entries are not touched by backfilling defaults" do
    perform_enqueued_jobs

    visit avo.edit_resources_user_path(User.first)

    fill_in "Shoe size", with: "10"

    save

    visit avo.edit_resources_meta_schema_path(schema)

    click_on "Add a new property"

    fill_in "Name", with: "driving_license"
    select "Text", from: find('select[name*="[schema_entries_attributes]["][name*="][as]"]')[:id]
    fill_in "Default", with: "B"

    save

    perform_enqueued_jobs

    # assert that backfilling worked but didn't touch the existing meta properties
    visit avo.resources_user_path(User.first)

    expect(find("[data-field-id=\"shoe_size\"]")).to have_text "10"
    expect(find("[data-field-id=\"driving_license\"]")).to have_text "B"
  end
end
