require "rails_helper"

RSpec.describe "StiPersonSpouse", type: :feature do
  let(:url) { "/admin/resources/people" }

  before do
    Avo::Resources::Person.with_temporary_items do
      field :name, as: :text, link_to_record: true, sortable: true, stacked: true
      field :type, as: :select, name: "Type", options: {Spouse: "Spouse", Sibling: "Sibling"}, include_blank: true
    end
  end

  after do
    Avo::Resources::Person.restore_items_from_backup
  end

  subject do
    visit url
  end

  describe "creating two models" do
    it "creates both models" do
      subject

      click_on "Create new person"

      fill_in "person_name", with: "John"

      click_on "Save"
      click_on "Go back"

      click_on "Create new person"

      fill_in "person_name", with: "Mary"
      select "Spouse", from: "person_type"

      click_on "Save"

      people = Person.all

      expect(people.first.name).to eq "John"
      expect(people.first.class.to_s).to eq "Person"

      expect(people.last.name).to eq "Mary"
      expect(people.last.class.to_s).to eq "Spouse"
    end
  end
end
