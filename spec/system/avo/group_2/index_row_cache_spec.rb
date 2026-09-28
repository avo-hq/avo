require "rails_helper"

# Regression spec for avo-hq/avo#1507.
#
# Index rows are fragment-cached under `Avo::Resources::Base#cache_hash`, a key
# built from the record and the resource file hash alone. Field `visible:`
# lambdas (and the grid card lambda) run inside that cached block, so whichever
# user renders a row first decides what every later visitor is served.
#
# The dummy app mounts Avo behind `authenticate :user, ->(user) { user.is_admin? }`,
# so every visitor here is an admin. The privileged column is gated on a second
# role (manager) instead, which is the same shape as an admin-only column in a
# host app.
RSpec.describe "Index row cache and the current user", type: :system do
  let(:admin) { create :user, roles: {admin: true, manager: false} }
  let!(:manager) { create :user, roles: {admin: true, manager: true} }
  let!(:spouse) { create :spouse, name: "Cache Probe" }

  around do |example|
    cache_setting = Avo.configuration.cache_resources_on_index_view
    perform_caching = ActionController::Base.perform_caching

    Avo.configuration.cache_resources_on_index_view = true
    ActionController::Base.perform_caching = true

    example.run
  ensure
    Avo.configuration.cache_resources_on_index_view = cache_setting
    ActionController::Base.perform_caching = perform_caching
  end

  before do
    Avo::Resources::Spouse.with_temporary_items do
      field :id, as: :id
      field :name, as: :text
      field :manager_notes, as: :text, name: "Manager notes", visible: -> { current_user.roles["manager"].present? } do
        "classified"
      end
    end
  end

  after do
    Avo::Resources::Spouse.restore_items_from_backup
  end

  # `admin` is signed in by TestHelpers::DisableAuthentication before each example.
  def switch_user_to(user)
    logout(:user)
    login_as user, scope: :user
  end

  describe "grid view" do
    around do |example|
      grid_view = Avo::Resources::Spouse.grid_view

      Avo::Resources::Spouse.grid_view = {
        card: -> do
          {
            title: record.name,
            body: current_user.roles["manager"].present? ? "classified" : "public"
          }
        end
      }

      example.run
    ensure
      Avo::Resources::Spouse.grid_view = grid_view
    end

    it "hides the manager-only card body from a plain admin after a manager warmed the cache" do
      switch_user_to manager
      visit avo.resources_spouses_path(view_type: :grid)
      expect(page).to have_css(".grid-card__description", text: "classified")

      switch_user_to admin
      visit avo.resources_spouses_path(view_type: :grid)
      expect(page).to have_text(spouse.name)

      expect(page).to have_css(".grid-card__description", text: "public")
      expect(page).not_to have_text("classified")
    end

    it "shows the manager-only card body to a manager after a plain admin warmed the cache" do
      visit avo.resources_spouses_path(view_type: :grid)
      expect(page).to have_css(".grid-card__description", text: "public")

      switch_user_to manager
      visit avo.resources_spouses_path(view_type: :grid)
      expect(page).to have_text(spouse.name)

      expect(page).to have_css(".grid-card__description", text: "classified")
      expect(page).not_to have_text("public")
    end
  end

  # On current code this passes for the wrong reason: the `return` inside the
  # `cache_if` block in `Avo::ViewTypes::TableComponent#cache_table_rows` exits
  # before Action View writes the fragment, so the table never caches anything
  # (one `read_fragment` per request, zero `write_fragment`). It stays as a
  # regression guard for when the table cache is made to actually write.
  describe "table view" do
    it "hides the manager-only column from a plain admin after a manager warmed the cache" do
      switch_user_to manager
      visit avo.resources_spouses_path
      expect(page).to have_css("th", text: "Manager notes")
      expect(page).to have_text("classified")

      switch_user_to admin
      visit avo.resources_spouses_path
      expect(page).to have_text(spouse.name)

      expect(page).not_to have_css("th", text: "Manager notes")
      expect(page).not_to have_text("classified")
    end
  end
end
