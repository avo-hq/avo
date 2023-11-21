require "rails_helper"

RSpec.feature "SkipShowView", type: :system do
  let!(:course) { create :course }
  let!(:post) { create :post }

  around do |example|
    # Store original configuration
    id_links_to_resource = Avo.configuration.id_links_to_resource
    resource_default_view = Avo.configuration.resource_default_view

    Avo.configuration.id_links_to_resource = true

    example.run

    # Restore original configuration after spec
    Avo.configuration.id_links_to_resource = id_links_to_resource
    Avo.configuration.resource_default_view = resource_default_view
  end

  describe "skip_show_view = true" do
    around do |example|
      Avo.configuration.resource_default_view = :edit
      example.run
      Avo.configuration.resource_default_view = :show
    end

    it "don't have the show button on each row of index" do
      visit "/admin/resources/courses"

      expect(page).to have_selector("[data-target='control:edit']")
      expect(page).not_to have_selector("[data-target='control:view']")
    end

    it "id link (id_links_to_resource) get edit page" do
      visit "/admin/resources/courses"

      find('[data-field-id="id"]').find("a").click
      wait_for_loaded

      expect(current_path).to eql "/admin/resources/courses/#{course.prefix_id}/edit"
    end

    it "create redirect to edit page" do
      visit "/admin/resources/courses"

      click_on "Create new course"
      wait_for_loaded

      fill_in "course_name", with: "Awesome course"
      click_on "Save"

      wait_for_loaded
      wait_for_loaded

      expect(current_path).to eql "/admin/resources/courses/#{Course.last.prefix_id}/edit"
    end

    it "can save and destroy on edit page" do
      visit "/admin/resources/courses/#{Course.last.prefix_id}/edit"

      expect(page).to have_selector("[data-control='destroy']")

      fill_in "course_name", with: "Awesome course (edited)"
      click_on "Save"
      wait_for_loaded

      expect(page).to have_text("Course updated!")
      expect(page).to have_text("Awesome course (edited)")
      expect(current_path).to eql "/admin/resources/courses/#{Course.last.prefix_id}/edit"

      accept_alert do
        click_on "Delete"
      end

      wait_for_loaded
      expect(page).to have_text("Course destroyed for ever!")
      # Actual behaviour of deleting a course is to redirect to new page
      expect(current_path).to eql "/admin/resources/courses/new"
    end

    it "create and delete association redirects to the edit page" do
      # Create
      visit "/admin/resources/course_links/new?via_relation=course&via_relation_class=Course&via_record_id=#{course.prefix_id}"

      fill_in "course_link_link", with: "Awesome course link"
      click_on "Save"

      expect(page).to have_text("Course link was successfully created.")
      expect(current_path).to eql "/admin/resources/courses/#{course.prefix_id}/edit"

      # Delete
      visit "/admin/resources/course_links/#{course.links.first.id}/edit?via_resource_class=Avo::Resources::Course&via_record_id=#{course.prefix_id}"

      accept_alert do
        click_on "Delete"
      end

      expect(page).to have_text("Record destroyed")
      expect(current_path).to eql "/admin/resources/courses/#{course.prefix_id}/edit"
    end

    it "grid item redirects to the edit page" do
      # Create
      visit "/admin/resources/posts"

      click_on post.name.to_s
      wait_for_loaded

      expect(current_path).to eql "/admin/resources/posts/#{post.slug}/edit"
    end
  end

  describe "skip_show_view = false" do
    before do
      Avo.configuration.resource_default_view = :show
    end

    it "have the show button on each row of index" do
      visit "/admin/resources/courses"

      expect(page).to have_selector("[data-target='control:edit']")
      expect(page).to have_selector("[data-target='control:view']")
    end

    it "id link (id_links_to_resource) get show page" do
      visit "/admin/resources/courses"

      find('[data-field-id="id"]').find("a").click
      wait_for_loaded

      expect(current_path).to eql "/admin/resources/courses/#{course.prefix_id}"
    end

    it "create redirect to show page" do
      visit "/admin/resources/courses"

      click_on "Create new course"
      wait_for_loaded

      fill_in "course_name", with: "Awesome course"
      click_on "Save"

      wait_for_loaded

      expect(current_path).to eql "/admin/resources/courses/#{Course.last.prefix_id}"
    end

    it "can save but can't destroy on edit page" do
      visit "/admin/resources/courses/#{Course.last.prefix_id}/edit"

      expect(page).to_not have_selector("[data-control='destroy']")

      fill_in "course_name", with: "Awesome course (edited)"
      click_on "Save"

      expect(page).to have_text("Course updated!")
      expect(page).to have_text("Awesome course (edited)")
      expect(current_path).to eql "/admin/resources/courses/#{Course.last.prefix_id}"

      accept_alert do
        click_on "Delete"
      end
      wait_for_loaded

      expect(page).to have_text("Course destroyed for ever!")
      # Actual behaviour of deleting a course is to redirect to new page
      expect(current_path).to eql "/admin/resources/courses/new"
    end

    it "create and delete association redirects to the show page" do
      # Create
      visit "/admin/resources/course_links/new?via_relation=course&via_relation_class=Course&via_record_id=#{course.prefix_id}"

      fill_in "course_link_link", with: "Awesome course link"
      click_on "Save"

      expect(page).to have_text("Course link was successfully created.")
      expect(current_path).to eql "/admin/resources/courses/#{course.prefix_id}"

      # Delete
      visit "/admin/resources/course_links/#{course.links.first.id}/edit?via_resource_class=Avo::Resources::Course&via_record_id=#{course.prefix_id}"
      expect(page).to_not have_selector("[data-control='destroy']")

      visit "/admin/resources/course_links/#{course.links.first.id}?via_resource_class=Avo::Resources::Course&via_record_id=#{course.prefix_id}"

      accept_alert do
        click_on "Delete"
      end
      wait_for_loaded

      expect(page).to have_text("Record destroyed")
      expect(current_path).to eql "/admin/resources/courses/#{course.prefix_id}"
    end

    it "grid item redirects to the show page" do
      # Create
      visit "/admin/resources/posts"

      click_on post.name.to_s
      wait_for_loaded

      expect(current_path).to eql "/admin/resources/posts/#{post.slug}"
    end
  end
end
