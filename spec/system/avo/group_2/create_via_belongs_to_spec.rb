# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Create Via Belongs to", type: :system do
  context "with nested belongs_to creation" do
    before do
      visit "/admin/resources/comments/new"
      fill_in "comment_body", with: "Preserved comment"
      select "Post", from: "comment_commentable_type"
      click_on "Create new post"
      within("turbo-frame#modal_frame") do
        fill_in "post_name", with: "Preserved post"
        click_on "Create new user"
      end
    end

    it "creates each record without losing its parent form", :aggregate_failures do
      expect(page).to have_css(".modal:popover-open", count: 2)
      expect(page).to have_field("post_name", with: "Preserved post")

      expect do
        within("turbo-frame#modal_frame_nested") do
          fill_in "user_email", with: "nested-user@example.com"
          fill_in "user_first_name", with: "Nested"
          fill_in "user_last_name", with: "User"
          fill_in "user_password", with: "password"
          fill_in "user_password_confirmation", with: "password"
          click_on "Save"
        end
      end.to change(User, :count).by(1)

      expect(page).to have_css("body.modal-open")
      expect(page).to have_css(".modal:popover-open", count: 1)
      expect(page).to have_field("post_name", with: "Preserved post")
      expect(page).to have_select("post_user_id", selected: "Nested User")

      expect do
        within("turbo-frame#modal_frame") { click_on "Save" }
      end.to change(Post, :count).by(1)

      expect(page).to have_field("comment_body", with: "Preserved comment")
      expect(page).to have_select("comment_commentable_id", selected: "Preserved post")
    end

    it "dismisses only the top dialog with Escape", :aggregate_failures do
      expect(page).to have_css(".modal:popover-open", count: 2)

      page.execute_script("document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }))")

      expect(page).to have_css(".modal:popover-open", count: 1)
      expect(page).to have_field("post_name", with: "Preserved post")
      expect(page).to have_css("body.modal-open")
    end
  end

  context "when a nested dialog fails validation" do
    it "re-renders it in its own frame and keeps every form underneath", :aggregate_failures do
      visit "/admin/resources/comments/new"
      fill_in "comment_body", with: "Preserved comment"
      select "Post", from: "comment_commentable_type"
      click_on "Create new post"
      within("turbo-frame#modal_frame") do
        fill_in "post_name", with: "Preserved post"
        click_on "Create new user"
      end

      within("turbo-frame#modal_frame_nested") do
        fill_in "user_email", with: "invalid-nested@example.com"
        click_on "Save"
      end

      within("turbo-frame#modal_frame_nested") do
        expect(page).to have_text "can't be blank"
        expect(page).to have_field("user_email", with: "invalid-nested@example.com")
      end
      expect(page).to have_css(".modal:popover-open", count: 2)
      expect(page).to have_field("post_name", with: "Preserved post")
      expect(page).to have_field("comment_body", with: "Preserved comment")

      expect do
        within("turbo-frame#modal_frame_nested") do
          fill_in "user_first_name", with: "Second"
          fill_in "user_last_name", with: "Try"
          fill_in "user_password", with: "password"
          fill_in "user_password_confirmation", with: "password"
          click_on "Save"
        end
        expect(page).to have_css(".modal:popover-open", count: 1)
      end.to change(User, :count).by(1)

      expect(page).to have_select("post_user_id", selected: "Second Try")
      expect(page).to have_field("post_name", with: "Preserved post")
    end
  end

  context "when each dialog closes with its Cancel button" do
    it "closes one level at a time and unlocks the page after the last one", :aggregate_failures do
      visit "/admin/resources/comments/new"
      select "Post", from: "comment_commentable_type"
      click_on "Create new post"
      within("turbo-frame#modal_frame") do
        fill_in "post_name", with: "Preserved post"
        click_on "Create new user"
      end
      expect(page).to have_css(".modal:popover-open", count: 2)

      within("turbo-frame#modal_frame_nested") { click_on "Cancel" }

      expect(page).to have_css(".modal:popover-open", count: 1)
      expect(page).to have_css("body.modal-open")
      expect(page).to have_field("post_name", with: "Preserved post")
      # Focus goes back to the dialog underneath, so Escape and Tab keep working in it.
      expect(page.evaluate_script("document.activeElement.matches('.modal:popover-open')")).to be true

      within("turbo-frame#modal_frame") { click_on "Cancel" }

      expect(page).not_to have_css(".modal:popover-open")
      expect(page).not_to have_css("body.modal-open")
    end
  end

  # Stacked dialogs of one resource hold fields with the same name and relation, so only the frame
  # the dialog was opened from tells the field that opened it apart from the one on the page.
  # A dialog disables the field it was opened through, hence the detour through `another_person`.
  context "with a belongs_to that references its own resource" do
    it "selects each new record in the dialog that opened it, three levels deep", :aggregate_failures do
      visit "/admin/resources/people/new"
      fill_in "person_name", with: "Level zero"
      within(field_wrapper(:person)) { click_on "Create new person" }

      within("turbo-frame#modal_frame") do
        fill_in "person_name", with: "Level one"
        within(field_wrapper(:another_person)) { click_on "Create new another person" }
      end

      within("turbo-frame#modal_frame_nested") do
        fill_in "person_name", with: "Level two"
        within(field_wrapper(:person)) { click_on "Create new person" }
      end

      expect(page).to have_css(".modal:popover-open", count: 3)

      expect do
        within("turbo-frame#modal_frame_nested_nested") do
          fill_in "person_name", with: "Level three"
          click_on "Save"
        end
        expect(page).to have_css(".modal:popover-open", count: 2)
      end.to change(Person, :count).by(1)

      expect(selected_person(:person, in_frame: "modal_frame_nested")).to eq "Level three"
      expect(selected_person(:person, in_frame: nil)).to eq "Choose an option"

      expect do
        within("turbo-frame#modal_frame_nested") { click_on "Save" }
        expect(page).to have_css(".modal:popover-open", count: 1)
      end.to change(Person, :count).by(1)

      expect(selected_person(:another_person, in_frame: "modal_frame")).to eq "Level two"
      expect(selected_person(:person, in_frame: nil)).to eq "Choose an option"

      expect do
        within("turbo-frame#modal_frame") { click_on "Save" }
        expect(page).not_to have_css(".modal:popover-open")
      end.to change(Person, :count).by(1)

      expect(selected_person(:person, in_frame: nil)).to eq "Level one"
      expect(page).to have_field("person_name", with: "Level zero")
    end

    # The selected option of a field in one dialog level (nil for the page), ignoring the levels on top of it.
    def selected_person(field_id, in_frame:)
      page.evaluate_script(<<~JS)
        (() => {
          const select = Array.from(document.querySelectorAll("[data-field-id='#{field_id}'] select"))
            .find((element) => (element.closest("turbo-frame[id^='modal_frame']")?.id ?? null) === #{in_frame.to_json})
          return select?.selectedOptions[0]?.text
        })()
      JS
    end
  end

  context "from an action's modal" do
    let!(:fish) { create :fish, name: "the action fish" }

    it "stacks the dialog on the action and selects the new record in it", :aggregate_failures do
      visit avo.resources_fish_index_path
      find("tr[data-resource-name=fish][data-record-id='#{fish.id}'] input[type=checkbox]").click
      open_panel_action(action_name: "Release fish")

      click_on "Create new user"

      expect(page).to have_css(".modal:popover-open", count: 2)

      expect do
        within("turbo-frame#modal_frame_nested") do
          fill_in "user_email", with: "action-user@example.com"
          fill_in "user_first_name", with: "Action"
          fill_in "user_last_name", with: "User"
          fill_in "user_password", with: "password"
          fill_in "user_password_confirmation", with: "password"
          click_on "Save"
        end
        expect(page).to have_css(".modal:popover-open", count: 1)
      end.to change(User, :count).by(1)

      expect(page).to have_select("fields_user_id", selected: "Action User")

      run_action

      expect(page).to have_text "1 fish released with message '' by Action User."
    end
  end

  describe "edit" do
    let(:course_link) { create(:course_link) }

    context "with non-searchable belongs_to" do
      let(:fish) { create(:fish, user: create(:user)) }

      it "successfully creates a new user and assigns it to the comment", :aggregate_failures do
        visit "/admin/resources/fish/#{fish.id}/edit"

        click_on "Create new user"

        expect do
          within("turbo-frame#modal_frame") do
            fill_in "user_email", with: "#{SecureRandom.hex(12)}@gmail.com"
            fill_in "user_first_name", with: "FirstName"
            fill_in "user_last_name", with: "LastName"
            fill_in "user_password", with: "password"
            fill_in "user_password_confirmation", with: "password"
            click_on "Save"
            sleep 0.2
          end
        end.to change(User, :count).by(1)

        expect(page).to have_select("fish_user_id", selected: User.last.name)

        click_on "Save"
        sleep 0.2

        expect(fish.reload.user).to eq User.last
      end
    end

    context "with polymorphic belongs_to" do
      let(:comment) { create(:comment, user: create(:user), commentable: create(:project)) }

      it "successfully creates a new commentable and assigns it to the comment", :aggregate_failures do
        visit "/admin/resources/comments/#{comment.to_param}/edit"

        page.select "Post", from: "comment_commentable_type"
        click_on "Create new post"

        expect do
          within("turbo-frame#modal_frame") do
            fill_in "post_name", with: "Test post"
            click_on "Save"
            sleep 0.2
          end
        end.to change(Post, :count).by(1)

        expect(page).to have_select("comment_commentable_id", selected: Post.last.name)

        click_on "Save"
        sleep 0.2

        expect(comment.reload.commentable).to eq Post.last
      end
    end
  end

  context "with non-searchable belongs_to" do
    it "successfully creates a new user and assigns it to the comment", :aggregate_failures do
      visit "/admin/resources/fish/new"

      click_on "Create new user"

      expect do
        within("turbo-frame#modal_frame") do
          fill_in "user_email", with: "#{SecureRandom.hex(12)}@gmail.com"
          fill_in "user_first_name", with: "FirstName"
          fill_in "user_last_name", with: "LastName"
          fill_in "user_password", with: "password"
          fill_in "user_password_confirmation", with: "password"
          click_on "Save"
          sleep 0.2
        end
      end.to change(User, :count).by(1)
      expect(User.last).to have_attributes(
        first_name: "FirstName",
        last_name: "LastName"
      )
      expect(page).to have_select("fish_user_id", selected: User.last.name)

      expect do
        click_on "Save"
        sleep 0.2
      end.to change(Fish, :count).by(1)

      expect(Fish.last.user).to eq User.last
    end

    context "when belongs_to record options exceeds associations_lookup_list_limit" do
      let!(:course) { create :course }
      let!(:exceeded_course) { create :course }

      before { Avo.configuration.associations_lookup_list_limit = 1 }
      after { Avo.configuration.associations_lookup_list_limit = 1000 }

      it "limits select options" do
        visit "/admin/resources/course_links/new"
        expect(page).to have_select "course_link_course_id", options: ["Choose an option", course.name, "There are more records available."]
        expect(page).to have_selector 'option[disabled="disabled"][value="There are more records available."]'
      end
    end
  end

  context "with polymorphic belongs_to" do
    it "successfully creates a new commentable and assigns it to the comment", :aggregate_failures do
      visit "/admin/resources/comments/new"

      fill_in "comment_body", with: "Test comment"

      page.select "Post", from: "comment_commentable_type"
      click_on "Create new post"

      expect do
        within("turbo-frame#modal_frame") do
          fill_in "post_name", with: "Test post"
          click_on "Save"
          sleep 0.2
        end
      end.to change(Post, :count).by(1)

      expect(page).to have_select("comment_commentable_id", selected: Post.last.name)

      expect do
        fill_in "comment_body", with: "Test Comment"
        click_on "Save"
        sleep 0.2
      end.to change(Comment, :count).by(1)

      expect(Comment.last).to have_attributes(
        body: "Test Comment",
        commentable: Post.last
      )
    end

    context "when belongs_to record options exceeds associations_lookup_list_limit" do
      let!(:user) { User.first }
      let!(:exceeded_user) { create :user }

      before { Avo.configuration.associations_lookup_list_limit = 1 }
      after { Avo.configuration.associations_lookup_list_limit = 1000 }

      it "limits select options" do
        visit "/admin/resources/comments/new"
        expect(page).to have_select "comment_user_id", options: ["Choose an option", user.name, "There are more records available."]
        expect(page).to have_selector 'option[disabled="disabled"][value="There are more records available."]'
      end
    end
  end

  context "with models that uses prefix_id" do
    it "successfully creates a new course and assigns it to the course link", :aggregate_failures do
      visit "/admin/resources/course_links/new"

      fill_in "course_link_link", with: "Test link"

      click_on "Create new course"

      expect do
        within("turbo-frame#modal_frame") do
          fill_in "course_name", with: "Test course"
          click_on "Save"
          sleep 0.2
        end
      end.to change(Course, :count).by(1)

      expect(page).to have_select("course_link_course_id", selected: Course.last.name)

      expect do
        click_on "Save"
        sleep 0.2
      end.to change(Course::Link, :count).by(1)

      expect(Course::Link.last).to have_attributes(
        link: "Test link",
        course: Course.last
      )
    end
  end

  context "disable" do
    it "dont show the link", :aggregate_failures do
      Avo::Resources::CourseLink.with_temporary_items do
        field :course, as: :belongs_to, searchable: true, can_create: false
      end

      visit "/admin/resources/course_links/new"

      within field_wrapper(:course) do
        expect(page).not_to have_text "Create new course"
      end
    ensure
      Avo::Resources::CourseLink.restore_items_from_backup
    end
  end
end
