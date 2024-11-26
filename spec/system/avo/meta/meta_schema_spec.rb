require "rails_helper"

RSpec.describe "MetaSchema", type: :system do
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
    select "string", from: find('select[name*="[schema_entries_attributes]["][name*="][type]"]')[:id]
    select "text", from: find('select[name*="[schema_entries_attributes]["][name*="][as]"]')[:id]

    save

    visit avo.resources_post_path(Post.first)

    expect(page).to have_text("GUEST AUTHOR NAME")
  end

  it "allows to add new entries to the user meta schema, which can instantly be used" do
    visit avo.resources_meta_schemas_path

    within "#avo_meta_schemas_list" do
      find("td", text: "User").click
    end

    click_on "Edit"

    click_on "Add a new property"

    fill_in "Name", with: "nickname"
    select "string", from: find('select[name*="[schema_entries_attributes]["][name*="][type]"]')[:id]
    select "text", from: find('select[name*="[schema_entries_attributes]["][name*="][as]"]')[:id]

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
end
