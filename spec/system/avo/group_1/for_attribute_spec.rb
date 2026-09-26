require "rails_helper"

RSpec.feature "for_attribute option", type: :system do
  let!(:user) { create :user }

  describe "text field" do
    let!(:fish) { create :fish }

    it "changing secondary field edits real value" do
      visit avo.edit_resources_fish_path(fish)

      fill_in "fish_secondary_field_for_name", with: "Cool fish name"

      save

      expect(page).to have_text "Fish was successfully updated."
      expect(page).to have_text "Cool fish name"
    end
  end

  describe "belongs_to field" do
    let!(:other_user) { create :user }
    let!(:fish) { create :fish, user: user }

    it "renders the association on index" do
      visit "/admin/resources/fish?view_type=table"

      within find("[data-resource-id='#{fish.to_param}'] [data-field-id='secondary_field_for_user']") do
        expect(page).to have_link user.name, href: avo.resources_user_path(user)
      end
    end

    it "renders the association on show" do
      visit avo.resources_fish_path(fish)

      expect(find_field_value_element("secondary_field_for_user")).to have_link user.name
    end

    it "prefills the select on edit" do
      visit avo.edit_resources_fish_path(fish)

      expect(page).to have_select "fish_user_id", selected: user.name
    end

    it "changing secondary field persists the association" do
      visit avo.edit_resources_fish_path(fish)

      select other_user.name, from: "fish_user_id"

      save

      expect(page).to have_text "Fish was successfully updated."
      expect(find_field_value_element("secondary_field_for_user")).to have_link other_user.name
      expect(fish.reload.user).to eq other_user
    end
  end

  describe "association fields" do
    let!(:project) { create :project }
    let!(:reviews) { create_list :review, 6, reviewable: project, user: user }
    let!(:review) { create :review, user: user }

    it "renders 2 tables for same association with different scopes" do
      visit avo.resources_project_path(project)

      scroll_to reviews_frame = find('turbo-frame[id="has_many_field_show_reviews"]')

      within reviews_frame do
        reviews.each do |review|
          find("[data-resource-name='reviews'][data-resource-id='#{review.id}']")
        end
      end

      scroll_to even_reviews_frame = find('turbo-frame[id="has_many_field_show_even_reviews"]')

      within even_reviews_frame do
        reviews.each do |review|
          if review.id % 2 == 0
            find("[data-resource-name='reviews'][data-resource-id='#{review.id}']")
          else
            expect(page).not_to have_selector("[data-resource-name='reviews'][data-resource-id='#{review.id}']")
          end
        end
      end
    end

    it "attach" do
      visit avo.resources_project_path(project)

      scroll_to find('turbo-frame[id="has_many_field_show_reviews"]')

      click_on "Attach even review"

      expect(page).to have_text "Choose even review"
      expect(page).to have_select "fields_related_id", selected: "Choose an option"

      select review.tiny_name, from: "fields_related_id"

      expect {
        within '[aria-modal="true"]' do
          click_on "Attach"
        end
        wait_for_loaded
      }.to change(project.reviews, :count).by 1

      expect(current_path).to eql avo.resources_project_path(project)

      within('turbo-frame[id="has_many_field_show_reviews"]') do
        expect(page).not_to have_text "Choose review"
        expect(page).not_to have_text "No related record found"
      end
    end
  end
end
