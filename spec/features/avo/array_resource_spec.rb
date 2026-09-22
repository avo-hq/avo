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
end
