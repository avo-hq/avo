require "rails_helper"

RSpec.feature "MissingResourceError", type: :system do
  around do |example|
    old_value = Capybara.raise_server_errors
    Capybara.raise_server_errors = false
    example.run
    Capybara.raise_server_errors = old_value
  end

  context "when has_one field" do
    let!(:store) { create :store }
    let!(:location) { create :location, store: store }

    it "shows informative error with suggested solution for missing resource" do
      visit "/admin/resources/stores/#{store.id}/location/#{location.id}?turbo_frame=has_one_field_show_location"

      expect(page).to have_content("Missing resource detected while rendering field for location.")
      expect(page).to have_content("You can generate that resource running 'rails generate avo:resource location'.")
      expect(page).to have_content("Alternatively use 'use_resource' option to specify the resource to be used on the field.")
      expect(page).to have_content("Check more at https://docs.avohq.io/3.0/resources.html.")
    end
  end

  context "when belongs_to field" do
    let!(:event) { create :event }

    it "shows informative error with suggested solution for missing resource" do
      visit "/admin/resources/events"

      expect(page).to have_content("Missing resource detected while rendering field for location.")
      expect(page).to have_content("You can generate that resource running 'rails generate avo:resource location'.")
      expect(page).to have_content("Alternatively use 'use_resource' option to specify the resource to be used on the field.")
      expect(page).to have_content("Check more at https://docs.avohq.io/3.0/resources.html.")
    end
  end

  context "when has_many field" do
    let!(:team) { create :team }

    it "shows informative error with suggested solution for missing resource" do
      visit "/admin/resources/teams/#{team.id}/locations?turbo_frame=has_many_field_show_locations"

      expect(page).to have_content("Missing resource detected while rendering field for locations.")
      expect(page).to have_content("You can generate that resource running 'rails generate avo:resource location'.")
      expect(page).to have_content("Alternatively use 'use_resource' option to specify the resource to be used on the field.")
      expect(page).to have_content("Check more at https://docs.avohq.io/3.0/resources.html.")
    end
  end

  context "when has_and_belongs_to_many field" do
    let!(:course) { create :course }

    it "shows informative error with suggested solution for missing resource" do
      visit "/admin/resources/courses/#{course.id}/locations?turbo_frame=has_and_belongs_to_many_field_show_locations"

      expect(page).to have_content("Missing resource detected while rendering field for locations.")
      expect(page).to have_content("You can generate that resource running 'rails generate avo:resource location'.")
      expect(page).to have_content("Alternatively use 'use_resource' option to specify the resource to be used on the field.")
      expect(page).to have_content("Check more at https://docs.avohq.io/3.0/resources.html.")
    end
  end
end
