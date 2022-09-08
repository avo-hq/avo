require 'rails_helper'

RSpec.feature "SkipShowView", type: :feature do
  let!(:course) { create :course }

  around do |example|
    # Store original configuration
    id_links_to_resource = Avo.configuration.id_links_to_resource
    skip_show_view = Avo.configuration.skip_show_view

    Avo.configuration.id_links_to_resource = true

    example.run

    # Restore original configuration after spec
    Avo.configuration.id_links_to_resource = id_links_to_resource
    Avo.configuration.skip_show_view = skip_show_view
  end

  describe "skip_show_view = true" do
    it "don't have the show button on each row of index" do
      Avo.configuration.skip_show_view = true
      visit "/admin/resources/courses"

      expect(page).to have_selector("[data-target='control:edit']")
      expect(page).not_to have_selector("[data-target='control:view']")
    end

    it "id link (id_links_to_resource) get edit page" do
      Avo.configuration.skip_show_view = true
      visit "/admin/resources/courses"

      find('[data-field-id="id"]').find("a").click
      wait_for_loaded

      expect(current_path).to eql "/admin/resources/courses/#{course.id}/edit"
    end

    it "create redirect to edit page" do
      Avo.configuration.skip_show_view = true
      visit "/admin/resources/courses"

      click_on "Create new course"
      wait_for_loaded

      fill_in "course_name", with: "Awesome course"
      click_on "Save"

      wait_for_loaded

      expect(current_path).to eql "/admin/resources/courses/#{Course.last.id}/edit"
    end

    it "can save and destroy on edit page" do
      Avo.configuration.skip_show_view = true
      visit "/admin/resources/courses/#{Course.last.id}/edit"

      expect(page).to have_selector("[data-control='destroy']")

      fill_in "course_name", with: "Awesome course (edited)"
      click_on "Save"

      expect(page).to have_text("Course updated!")
      expect(page).to have_text("Awesome course (edited)")
      expect(current_path).to eql "/admin/resources/courses/#{Course.last.id}/edit"


      click_on "Delete"
      expect(page).to have_text("Course destroyed for ever!")
      # Actual behaviour of deleting a course is to redirect to new page
      expect(current_path).to eql "/admin/resources/courses/new"
    end
  end

  describe "skip_show_view = false" do
    it "have the show button on each row of index" do
      Avo.configuration.skip_show_view = false
      visit "/admin/resources/courses"

      expect(page).to have_selector("[data-target='control:edit']")
      expect(page).to have_selector("[data-target='control:view']")
    end

    it "id link (id_links_to_resource) get show page" do
      Avo.configuration.skip_show_view = false
      visit "/admin/resources/courses"

      find('[data-field-id="id"]').find("a").click
      wait_for_loaded

      expect(current_path).to eql "/admin/resources/courses/#{course.id}"
    end

    it "create redirect to show page" do
      Avo.configuration.skip_show_view = false
      visit "/admin/resources/courses"

      click_on "Create new course"
      wait_for_loaded

      fill_in "course_name", with: "Awesome course"
      click_on "Save"

      wait_for_loaded

      expect(current_path).to eql "/admin/resources/courses/#{Course.last.id}"
    end

    it "can save but can't destroy on edit page" do
      Avo.configuration.skip_show_view = false
      visit "/admin/resources/courses/#{Course.last.id}/edit"

      expect(page).to_not have_selector("[data-control='destroy']")

      fill_in "course_name", with: "Awesome course (edited)"
      click_on "Save"

      expect(page).to have_text("Course updated!")
      expect(page).to have_text("Awesome course (edited)")
      expect(current_path).to eql "/admin/resources/courses/#{Course.last.id}"
    end
  end

 end
