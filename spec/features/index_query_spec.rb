require "rails_helper"

RSpec.describe "IndexQuery", type: :feature do
  let!(:person_1) { create :person, name: "person - 1", user_id: user.id }
  let!(:person_2) { create :person, name: "person - 2", user_id: user.id }
  let(:user) { create :user, first_name: "aaaaa", last_name: "Aaandy" }

  context "index" do
    it "displays the people in descending order by created_at" do
      visit "/admin/resources/people"

      wait_for_loaded

      people = all('[data-field-id="name"]')

      first_person = people[0].find("a").text
      second_person = people[1].find("a").text

      expect(first_person).to eq person_2.name
      expect(second_person).to eq person_1.name
    end
  end

  context "when loaded via association" do
    it "displays the people in ascending order by name" do
      visit "admin/resources/users/john-rambo"

      wait_for_loaded

      find('a[data-selected="false"][data-tabs-tab-name-param="People"]', match: :first).click
      people = all('[data-field-id="name"]')

      first_person = people[0].find("a").text
      second_person = people[1].find("a").text

      expect(first_person).to eq person_1.name
      expect(second_person).to eq person_2.name
    end
  end
end
