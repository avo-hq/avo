# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Create Via Belongs to", type: :system do
  describe "edit" do
    let(:course_link) { create(:course_link) }

    context "with searchable belongs_to" do
      it "successfully creates a new course and assigns it to the course link", :aggregate_failures do
        visit "/admin/resources/course_links/#{course_link.id}/edit"

        click_on "Create new course"

        expect {
          within('.modal-container') do
            fill_in "course_name", with: "Test course"
            click_on "Save"
            sleep 0.2
          end
        }.to change(Course, :count).by(1)

        expect(find_field(id: "course_link_course_id").value).to eq "Test course"

        click_on "Save"
        sleep 0.2

        expect(course_link.reload.course).to eq Course.last
      end
    end

    context "with polymorphic belongs_to" do
    end

    context "with searchable, polymorphic belongs_to" do
    end

    context "with non-searchable belongs_to" do
      let(:fish) { create(:fish, user: create(:user)) }

      it 'successfully creates a new user and assigns it to the comment', :aggregate_failures do
        visit "/admin/resources/fish/#{fish.id}/edit"

        click_on "Create new user"

        expect {
          within('.modal-container') do
            fill_in "user_email", with: "#{SecureRandom.hex(12)}@gmail.com"
            fill_in "user_first_name", with: "FirstName"
            fill_in "user_last_name", with: "LastName"
            fill_in "user_password", with: "password"
            fill_in "user_password_confirmation", with: "password"
            click_on "Save"
            sleep 0.2
          end
        }.to change(User, :count).by(1)
        expect(User.last).to have_attributes(
                               first_name: "FirstName",
                               last_name: "LastName",
                             )
        expect(page).to have_select('fish_user_id', selected: User.last.name)

        click_on "Save"
        sleep 0.2

        expect(fish.reload.user).to eq User.last
      end
    end
  end

  describe "new" do
    context "with searchable belongs_to" do
      it 'successfully creates a new course and assigns the value to the field in the form' do
        visit "/admin/resources/course_links/new"

        click_on "Create new course"

        expect {
          within('.modal-container') do
            fill_in "course_name", with: "Test course"
            click_on "Save"
            sleep 0.2
          end
        }.to change(Course, :count).by(1)

        expect(find_field(id: "course_link_course_id").value).to eq "Test course"

        expect {
          fill_in("course_link_link", with: "https://www.example.com")
          click_on "Save"
          sleep 0.2
        }.to change(Course::Link, :count).by(1)

        expect(Course::Link.last.course).to eq Course.last
      end
    end
  end

  context "with non-searchable belongs_to" do
    it 'successfully creates a new user and assigns it to the comment', :aggregate_failures do
      visit "/admin/resources/fish/new"

      click_on "Create new user"

      expect {
        within('.modal-container') do
          fill_in "user_email", with: "#{SecureRandom.hex(12)}@gmail.com"
          fill_in "user_first_name", with: "FirstName"
          fill_in "user_last_name", with: "LastName"
          fill_in "user_password", with: "password"
          fill_in "user_password_confirmation", with: "password"
          click_on "Save"
          sleep 0.2
        end
      }.to change(User, :count).by(1)
      expect(User.last).to have_attributes(
                             first_name: "FirstName",
                             last_name: "LastName",
                             )
      expect(page).to have_select('fish_user_id', selected: User.last.name)

      expect {
        click_on "Save"
        sleep 0.2
      }.to change(Fish, :count).by(1)

      expect(Fish.last.user).to eq User.last
    end
  end
end
