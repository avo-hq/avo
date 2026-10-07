require "rails_helper"

RSpec.feature "ArrayResource", type: :feature do
  describe "from index to show" do
    it "render the movies index using the def records resource method and navigate to show" do
      visit path = avo.resources_movies_path(per_page: 12)

      expect(find("table thead").text).to eq "Select all\nID\nName\nRelease date\nFun fact"
      expect(page).to have_text "The Shawshank Redemption"
      expect(page).to have_text "The iconic cat in the opening scene was a stray..."

      first("a[href=\"#{path}&page=2\"]").click
      expect(find("table thead").text).to eq "Select all\nID\nName\nRelease date"

      expect(page).to have_text "The Lord of the Rings: The Fellowship of the Ring"

      first("a[href=\"#{path}&page=3\"]").click

      first('a[href="/admin/resources/movies/28"]').click

      within("div.resource-sidebar-component") do
        fun_fact_text = find('div[data-field-id="fun_fact"] [data-slot="value"]').text
        expect(fun_fact_text).to eq "Ryan Gosling learned to play the piano for his role, mastering several songs within three months."
      end
    end

    it "render the attendees index using the def records resource method and navigate to show" do
      visit avo.resources_attendees_path

      expect(find("table thead").text).to eq "Select all\nID\nName"
      expect(page).to have_text User.first.name

      first("a[href=\"#{avo.resources_attendee_path User.first}\"]").click

      name = find('div[data-field-id="name"] [data-slot="value"]').text
      expect(name).to eq User.first.name
    end

    it "ignores a sort it cannot apply" do
      visit avo.resources_movies_path(sort_by: "name", sort_direction: "desc")

      expect(page).to have_text "The Shawshank Redemption"
    end
  end

  describe "model class" do
    # YARD, a development dependency, adds Module#class_name. Host apps don't have it, and it
    # hides a missing class_name on the generated model class, so remove it for these examples.
    around do |example|
      yard_class_name = Module.instance_method(:class_name) if Module.method_defined?(:class_name)
      Module.send(:remove_method, :class_name) if yard_class_name

      example.run
    ensure
      Module.send(:define_method, :class_name, yard_class_name) if yard_class_name
    end

    it "returns the records from .all" do
      expect(Avo::Resources::Movie.model_class.all.map(&:name)).to include "The Shawshank Redemption"
    end

    # So any controller can list it, not only Avo::ArrayController.
    it "answers its records as its query scope" do
      expect(Avo::Resources::Movie.query_scope.map(&:name)).to include "The Shawshank Redemption"
    end

    it "returns the resource class name" do
      expect(Avo::Resources::Movie.model_class.class_name).to eq "Movie"
    end

    it "builds records that are instances of model_class" do
      resource = Avo::Resources::Movie.new
      records = resource.fetch_records

      expect(records).to all(be_a(resource.model_class))
      expect(records.first.class.class_name).to eq "Movie"
      expect(records.first.class.all.map(&:id)).to eq records.map(&:id)
    end

    it "is not shared between array resources" do
      Avo::Resources::Attendee.new.fetch_records

      expect(Avo::Resources::Attendee.model_class).to eq User
      expect(Avo::Resources::Movie.model_class).not_to eq User
    end

    it "renders the show page when the policy scope calls scope.all" do
      # Pundit's default Scope#resolve is `scope.all`
      allow_any_instance_of(Avo::Services::AuthorizationService).to receive(:apply_policy) { |_service, query| query.all }

      visit avo.resources_movie_path(28)

      expect(page).to have_text "La La Land"
    end
  end

  describe "writes" do
    it "hides the create, edit and delete controls by default" do
      visit avo.resources_movies_path

      expect(page).not_to have_css "[data-target='create']"
      expect(page).not_to have_css "[data-target='control:edit']"

      visit avo.resources_movie_path(1)

      expect(page).not_to have_css "[data-target='control:edit']"
      expect(page).not_to have_css "[data-target='control:destroy']"
    end

    context "when the resource is writable" do
      around do |example|
        Avo::Resources::Movie.writable = true
        example.run
      ensure
        Avo::Resources::Movie.writable = false
      end

      it "shows the create, edit and delete controls" do
        visit avo.resources_movies_path

        expect(page).to have_css "[data-target='create']"
        expect(page).to have_css "[data-target='control:edit']"

        visit avo.resources_movie_path(1)

        expect(page).to have_css "a[href^='/admin/resources/movies/1/edit']"
        expect(page).to have_css "[data-target='control:destroy']"
      end

      it "fills a new record from the form and hands it to the resource to save" do
        saved = nil
        allow_any_instance_of(Avo::Resources::Movie).to receive(:save_record) do |_resource, record|
          saved = record
          saved.id = 1
        end

        visit avo.new_resources_movie_path
        fill_in "movie_name", with: "Heat"
        click_on "Save"

        expect(saved.name).to eq "Heat"
      end

      it "fills an existing record from the edit form and hands it to the resource to save" do
        saved = nil
        allow_any_instance_of(Avo::Resources::Movie).to receive(:save_record) do |_resource, record|
          saved = record
        end

        visit avo.edit_resources_movie_path(1)
        fill_in "movie_name", with: "Shawshank"
        click_on "Save"

        expect(saved.id).to eq 1
        expect(saved.name).to eq "Shawshank"
      end

      it "hands the record to the resource to destroy" do
        destroyed = nil
        allow_any_instance_of(Avo::Resources::Movie).to receive(:destroy_record) do |_resource, record|
          destroyed = record
        end

        page.driver.submit :delete, avo.resources_movie_path(1), {}

        expect(destroyed.id).to eq 1
      end
    end
  end
end
