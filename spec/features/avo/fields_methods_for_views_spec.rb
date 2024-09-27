require "rails_helper"

RSpec.feature "Fields methods for each view", type: :feature do
  let!(:links) { create_list :course_link, 3 }
  let!(:attach_link) { create :course_link }
  let!(:course) { create :course, links: links }

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
      original_show_fields = Avo::Resources::Course.instance_method(:show_fields)

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
        define_method(:show_fields, original_show_fields)
      end
    end

    it "shows only the specified fields for index view" do
      original_index_fields = Avo::Resources::Course.instance_method(:index_fields)

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
        define_method(:index_fields, original_index_fields)
      end
    end

    it "shows only the specified fields for display views" do
      # Store the original method
      original_show_fields = Avo::Resources::Course.instance_method(:show_fields)
      original_index_fields = Avo::Resources::Course.instance_method(:index_fields)

      Avo::Resources::Course.class_eval do
        remove_method :show_fields
        remove_method :index_fields

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


      # Restore the original method
      Avo::Resources::Course.class_eval do
        define_method(:show_fields, original_show_fields)
        define_method(:index_fields, original_index_fields)
      end
    end

    it "shows only the specified fields for form views" do
      # Store the original method
      original_form_fields = Avo::Resources::Course.instance_method(:form_fields)

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

      # Restore the original method
      Avo::Resources::Course.class_eval do
        define_method(:form_fields, original_form_fields)
      end
    end

    it "detach works using show and index fields api" do
      visit "#{Avo::Engine.routes.url_helpers.resources_course_path(course)}/links?view=show"

      expect {
        find("tr[data-resource-id='#{course.links.first.to_param}'] [data-control='detach']").click
      }.to change(course.links, :count).by(-1)
    end

    it "attach works using show and index fields api" do
      visit "#{Avo::Engine.routes.url_helpers.resources_course_path(course)}/links?view=show"

      click_on "Attach link"

      expect(page).to have_text "Choose link"

      select attach_link.link, from: "fields_related_id"

      expect {
        within '[aria-modal="true"]' do
          click_on "Attach"
        end
        wait_for_loaded
      }.to change(course.links, :count).by 1
    end
  end
end
