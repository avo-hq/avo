require "rails_helper"

RSpec.describe "QueryScope", type: :system do
  describe "for user order by last name" do
    let!(:user_c) { create :user, first_name: "ccccc", last_name: "Aandy" }
    let!(:user_a) { create :user, first_name: "ccccc", last_name: "Aaaandy" }
    let!(:user_b) { create :user, first_name: "aaaaa", last_name: "Aaandy" }

    context "index" do
      it "displays the users in ascending order by last_name" do
        visit "/admin/resources/users"

        wait_for_loaded

        users_ids = all('[data-field-type="id"]')

        first_user_id = users_ids[0].find("a").text
        first_user_lastname = User.find(first_user_id).last_name
        second_user_id = users_ids[1].find("a").text
        second_user_lastname = User.find(second_user_id).last_name
        third_user_id = users_ids[2].find("a").text
        third_user_lastname = User.find(third_user_id).last_name

        expect(first_user_lastname).to eq user_a.last_name
        expect(second_user_lastname).to eq user_b.last_name
        expect(third_user_lastname).to eq user_c.last_name
      end
    end

    it "displays the users in ascending order by id" do
      visit "/admin/resources/users?sort_by=id&sort_direction=asc"

      wait_for_loaded

      users_ids = all('[data-field-type="id"]')

      first_user_id = users_ids[0].find("a").text
      second_user_id = users_ids[1].find("a").text
      third_user_id = users_ids[2].find("a").text

      expect(first_user_id).to eq User.all[0].id.to_s
      expect(second_user_id).to eq User.all[1].id.to_s
      expect(third_user_id).to eq User.all[2].id.to_s
    end

    it "displays the users according to the logic of a proc provided to sortable" do
      visit "/admin/resources/users?sort_by=is_writer&sort_direction=asc"

      wait_for_loaded

      users_ids = all('[data-field-type="id"]')

      first_user_id = users_ids[0].find("a").text.to_i
      second_user_id = users_ids[1].find("a").text.to_i
      third_user_id = users_ids[2].find("a").text.to_i

      all_ids = [first_user_id, second_user_id, third_user_id]

      expect(all_ids).to eq all_ids.sort
    end
  end
end
