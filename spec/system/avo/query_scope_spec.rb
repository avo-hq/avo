require "rails_helper"

RSpec.describe "QueryScope", type: :system do
  describe "for user order by last name" do
    let!(:user_c) { create :user, last_name: 'Aandy' }
    let!(:user_a) { create :user, last_name: 'Aaaandy' }
    let!(:user_b) { create :user, last_name: 'Aaandy' }

    context "index" do
      it "displays the users in ascending order by last_name" do
        visit "/admin/resources/users"

        first_user_id = all('[data-field-type="id"]')[0].find("a").text
        first_user_lastname = User.find(first_user_id).last_name
        second_user_id = all('[data-field-type="id"]')[1].find("a").text
        second_user_lastname = User.find(second_user_id).last_name
        third_user_id = all('[data-field-type="id"]')[2].find("a").text
        third_user_lastname = User.find(third_user_id).last_name

        expect(first_user_lastname).to eq user_a.last_name
        expect(second_user_lastname).to eq user_b.last_name
        expect(third_user_lastname).to eq user_c.last_name
      end
    end

    it "displays the users in ascending order by id" do
      visit "/admin/resources/users?sort_by=id&sort_direction=asc"

      first_user_id = all('[data-field-type="id"]')[0].find("a").text
      second_user_id = all('[data-field-type="id"]')[1].find("a").text
      third_user_id = all('[data-field-type="id"]')[2].find("a").text

      expect(first_user_id).to eq User.all[0].id.to_s
      expect(second_user_id).to eq User.all[1].id.to_s
      expect(third_user_id).to eq User.all[2].id.to_s
    end
  end
end
