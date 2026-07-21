# frozen_string_literal: true

require "rails_helper"

RSpec.describe "self.table_view row_options", type: :feature do
  include_context "has_admin_user"

  after do
    Avo::Resources::User.table_view = nil
  end

  describe "on the main index" do
    before do
      Avo::Resources::User.table_view = {
        row_options: {
          class: -> { "row--admin" if record.is_admin? },
          data: -> { {test_id: "user-#{record.id}"} }
        }
      }
    end

    it "applies the conditional class to admin rows" do
      admin
      User.create!(first_name: "Reg", last_name: "User", email: "regular@example.com", password: "secret123")

      visit avo.resources_users_path

      expect(page).to have_css("tr.row--admin")
      admin_row = page.find("tr[data-test-id='user-#{admin.id}']")
      expect(admin_row[:class]).to include("row--admin")
    end

    it "preserves Avo's class tokens alongside user classes" do
      admin
      visit avo.resources_users_path

      expect(page).to have_css("tr.table-row.row--admin")
    end

    it "preserves Avo's data-controller token list when user adds a data attribute" do
      Avo::Resources::User.table_view = {
        row_options: {data: {controller: "my-row-controller"}}
      }
      admin
      visit avo.resources_users_path

      controllers = page.first("tr.table-row")[:"data-controller"].split(/\s+/)
      expect(controllers).to include("item-selector")
      expect(controllers).to include("my-row-controller")
    end
  end

  describe "view local" do
    before do
      Avo::Resources::User.table_view = {
        row_options: {class: -> { "context-#{view}" }}
      }
    end

    it "resolves to :index on the main index" do
      admin
      visit avo.resources_users_path

      expect(page).to have_css("tr.context-index")
    end

    it "resolves to :has_many inside an association panel" do
      project = create(:project)
      project.users << admin
      visit "/admin/resources/projects/#{project.to_param}/users?turbo_frame=has_many_field_show_users"

      expect(page).to have_css("tr.context-has_many")
      expect(page).not_to have_css("tr.context-index")
    end
  end

  describe "without table_view configured" do
    it "renders rows identically to before the feature shipped" do
      admin
      visit avo.resources_users_path

      tr = page.first("tr.table-row")
      expect(tr[:class]).to include("table-row", "group", "z-21", "cursor-pointer", "relative", "has-row-link")
      expect(tr[:"data-record-id"]).to eq(admin.to_param)
    end
  end
end
