require 'rails_helper'

RSpec.feature "Fields methods for each view", type: :feature do
  let!(:course) { create :course }

  context "with `fields` declaration" do
    it "shows all the fields" do
      visit Avo::Engine.routes.url_helpers.resources_course_path(course)

      expect(page).to have_css "[data-field-id='id']"
      expect(page).to have_css "[data-field-id='name']"
      expect(page).to have_css "[data-field-id='has_skills']"
      expect(page).to have_css "[data-field-id='skills']"
      expect(page).to have_css "[data-field-id='starting_at']"
      expect(page).to have_css "[data-field-id='country']"
      expect(page).to have_css "[data-field-id='city']"
      expect(page).to have_selector 'turbo-frame[id="has_many_field_show_links"]'
    end
  end

  context "with `view_fields` declaration" do
    it "shows only the specified fields for show view" do
      Avo::Resources::Course.class_eval do
        def show_fields
          field :name, as: :text
          field :has_skills, as: :boolean
          field :skills, as: :textarea
        end
      end

      visit Avo::Engine.routes.url_helpers.resources_course_path(course)

      expect(page).not_to have_css "[data-field-id='id']"
      expect(page).to have_css "[data-field-id='name']"
      expect(page).to have_css "[data-field-id='has_skills']"
      expect(page).to have_css "[data-field-id='skills']"
      expect(page).not_to have_css "[data-field-id='starting_at']"
      expect(page).not_to have_css "[data-field-id='country']"
      expect(page).not_to have_css "[data-field-id='city']"
      expect(page).not_to have_selector 'turbo-frame[id="has_many_field_show_links"]'

      Avo::Resources::Course.class_eval do
        remove_method :show_fields
      end
    end

    it "shows only the specified fields for index view" do
      Avo::Resources::Course.class_eval do
        def index_fields
          field :id, as: :id
          field :name, as: :text
        end
      end

      visit Avo::Engine.routes.url_helpers.resources_courses_path

      expect(page).to have_css "[data-field-id='id']"
      expect(page).to have_css "[data-field-id='name']"
      expect(page).not_to have_css "[data-field-id='has_skills']"
      expect(page).not_to have_css "[data-field-id='skills']"
      expect(page).not_to have_css "[data-field-id='starting_at']"
      expect(page).not_to have_css "[data-field-id='country']"
      expect(page).not_to have_css "[data-field-id='city']"
      expect(page).not_to have_selector 'turbo-frame[id="has_many_field_show_links"]'

      Avo::Resources::Course.class_eval do
        remove_method :index_fields
      end
    end

    it "shows only the specified fields for display views" do
      Avo::Resources::Course.class_eval do
        def display_fields
          field :id, as: :id
          field :name, as: :text
          field :has_skills, as: :boolean
          field :skills, as: :textarea
          field :starting_at, as: :time
        end
      end

      visit Avo::Engine.routes.url_helpers.resources_courses_path

      expect(page).to have_css "[data-field-id='id']"
      expect(page).to have_css "[data-field-id='name']"
      expect(page).to have_css "[data-field-id='has_skills']"
      expect(page).not_to have_css "[data-field-id='skills']"
      expect(page).to have_css "[data-field-id='starting_at']"
      expect(page).not_to have_css "[data-field-id='country']"
      expect(page).not_to have_css "[data-field-id='city']"
      expect(page).not_to have_selector 'turbo-frame[id="has_many_field_show_links"]'

      visit Avo::Engine.routes.url_helpers.resources_course_path(course)

      expect(page).to have_css "[data-field-id='id']"
      expect(page).to have_css "[data-field-id='name']"
      expect(page).to have_css "[data-field-id='has_skills']"
      expect(page).to have_css "[data-field-id='skills']"
      expect(page).to have_css "[data-field-id='starting_at']"
      expect(page).not_to have_css "[data-field-id='country']"
      expect(page).not_to have_css "[data-field-id='city']"
      expect(page).not_to have_selector 'turbo-frame[id="has_many_field_show_links"]'


      Avo::Resources::Course.class_eval do
        remove_method :display_fields
      end
    end

    it "shows only the specified fields for form views" do
      Avo::Resources::Course.class_eval do
        def form_fields
          field :name, as: :text
          field :has_skills, as: :boolean
          field :skills, as: :textarea
        end
      end

      visit Avo::Engine.routes.url_helpers.new_resources_course_path

      expect(page).not_to have_css "[data-field-id='id']"
      expect(page).to have_css "[data-field-id='name']"
      expect(page).to have_css "[data-field-id='has_skills']"
      expect(page).to have_css "[data-field-id='skills']"
      expect(page).not_to have_css "[data-field-id='starting_at']"
      expect(page).not_to have_css "[data-field-id='country']"
      expect(page).not_to have_css "[data-field-id='city']"
      expect(page).not_to have_selector 'turbo-frame[id="has_many_field_show_links"]'

      visit Avo::Engine.routes.url_helpers.edit_resources_course_path(course)

      expect(page).not_to have_css "[data-field-id='id']"
      expect(page).to have_css "[data-field-id='name']"
      expect(page).to have_css "[data-field-id='has_skills']"
      expect(page).to have_css "[data-field-id='skills']"
      expect(page).not_to have_css "[data-field-id='starting_at']"
      expect(page).not_to have_css "[data-field-id='country']"
      expect(page).not_to have_css "[data-field-id='city']"
      expect(page).not_to have_selector 'turbo-frame[id="has_many_field_show_links"]'


      Avo::Resources::Course.class_eval do
        remove_method :form_fields
      end
    end
  end
end
