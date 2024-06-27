require "rails_helper"

RSpec.describe "Tags", type: :system do
  describe "acts_as_taggable" do
    let!(:post) { create :post, tag_list: [] }

    context "show" do
      let(:path) { "/admin/resources/posts/#{post.id}" }

      it "shows empty state" do
        visit path

        expect(find_field_value_element("tags")).to have_text empty_dash
      end

      it "shows filled state" do
        post.tag_list = ["some", "tags", "here", "and", "there"]
        post.save

        visit path

        expect(find_field_value_element("tags")).not_to have_text empty_dash
        expect(find_field_value_element("tags")).not_to have_text "some tags here and there"
      end
    end

    context "index" do
      let(:path) { "/admin/resources/posts?view_type=table" }

      it "shows empty state" do
        visit path

        # sleep 10
        expect(field_element_by_resource_id("tags", post.slug)).to have_text empty_dash
      end

      it "shows filled state" do
        post.tag_list = ["some", "tags", "here", "and", "there"]
        post.save

        visit path

        field_element = field_element_by_resource_id("tags", post.slug)

        expect(field_element).not_to have_text empty_dash
        expect(field_element).not_to have_text "some tags here ..."

        field_element.find('[data-target="tag-component"]', text: "...").hover
        expect(page).to have_text "2 more items"
      end
    end

    context "edit" do
      let(:path) { "/admin/resources/posts/#{post.id}/edit" }
      let(:tag_input) { tags_element(find_field_value_element("tags")) }
      let(:input_textbox) { 'span[contenteditable][data-placeholder="add some tags"]' }

      it "shows empty state" do
        visit path

        expect(find_field_value_element("tags")).to have_selector "tags.tagify"
        expect(tag_input).not_to have_selector "tag"
      end

      it "shows filled state" do
        post.tag_list = ["some", "tags", "here", "and", "there"]
        post.save

        visit path

        expect(tag_input).to have_selector "tag", count: 5
        expect(tag_input).to have_selector input_textbox
      end

      it "adds a tag" do
        post.tag_list = ["some", "tags", "here", "and", "there"]
        post.save

        visit path

        tag_input.find(input_textbox).click
        tag_input.find(input_textbox).set("one, two, five,")
        sleep 0.3

        save

        expect(post.reload.tag_list.sort).to eq ["1", "2"].sort
      end
    end

    context "new" do
      it "keeps acts as taggable tags on validation errors" do
        visit avo.new_resources_post_path

        add_tag(field: :tags, tag: "one")
        add_tag(field: :tags, tag: "two")
        add_tag(field: :tags, tag: "five")

        save

        expect(page).to have_text("Validation failed: Name can't be blank")
        expect(page.all(".tagify__tag-text").map(&:text)).to eq ["one", "two"]
      end
    end
  end

  describe 'without acts_as_taggable' do
    let(:course) { create :course, skills: [] }
    let(:path) { "/admin/resources/courses/#{course.id}/edit" }
    let(:tag_input) { tags_element(find_field_value_element("skills")) }
    let(:input_textbox) { 'span[contenteditable][data-placeholder="Skills"]' }

    it "adds skills" do
      course.skills = ["some", "skills"]
      course.save

      visit path

      tag_input.find(input_textbox).click
      tag_input.find(input_textbox).set("one, two, three,")
      sleep 0.3

      save

      expect(course.reload.skills.sort).to eq ["some", "skills", "one", "two", "three"].sort
    end
  end

  describe "ajax request" do
    let(:field_value_slot) { tags_element(find_field_value_element("user_id")) }
    let(:tags_input) { field_value_slot.find("span[contenteditable]") }
    let!(:zezel) { create :user, first_name: "Zezel", last_name: "Nunu" }
    let!(:users) { create_list :user, 15 }

    it "fetches the users" do
      expect(TestBuddy).to receive(:hi).with(zezel.id.to_s).at_least :once

      visit "/admin/resources/users/#{admin.slug}"
      open_panel_action(action_name: "Toggle inactive")

      tags_input.click
      tags_input.set("Zezel")
      wait_for_tags_to_load(field_value_slot)
      type(:down, :return)

      sleep 0.3
      click_on "Run"
    end
  end

  describe "fetch labels" do
    let!(:users) { create_list :user, 2 }
    let!(:courses) { create_list :course, 2, skills: users.pluck(:id) }

    it "fetches the labels" do
      Avo::Resources::Course.with_temporary_items do
        field :skills, as: :tags,
          fetch_labels: -> {
            User.where(id: record.skills)
              .pluck(:first_name, :last_name)
              .map { |first_name, last_name| "FL #{first_name} #{last_name}" }
          }
      end

      visit "/admin/resources/courses"

      expect(page).to have_text "FL #{users[0].first_name} #{users[0].last_name}"
      expect(page).to have_text "FL #{users[1].first_name} #{users[1].last_name}"

      Avo::Resources::Course.restore_items_from_backup
    end
  end

  describe "format_using (same as deprecated fetch_labels) with fetch_values_from" do
    let!(:users) { create_list :user, 2, first_name: "Bob" }
    let!(:courses) { create_list :course, 2, skills: users.pluck(:id) }

    it "fetches the labels" do
      ENV["TESTING_TAGS_FORMAT_USING"] = "1"

      visit avo.resources_course_path(courses.first)
      expect(page).to have_text "#{users[0].first_name} #{users[0].last_name}"

      visit avo.resources_course_path(courses.last)
      expect(page).to have_text "#{users[1].first_name} #{users[1].last_name}"
    end

    it "keep correct tags on validations error and edit" do
      visit avo.new_resources_course_path

      input_element = find(".tagify__input")
      input_element.click
      input_element.send_keys("Bob")
      sleep 1
      input_element.send_keys(:enter)
      sleep 1
      save

      expect(page).to have_text "Name can't be blank"
      expect(page).to have_text "#{users[0].first_name} #{users[0].last_name}"

      fill_in "course_name", with: "The course"

      input_element = find(".tagify__input")
      input_element.click
      input_element.send_keys("Bob")
      sleep 1
      input_element.send_keys(:enter)
      sleep 1
      save

      expect(Course.last.skills.map(&:to_i)).to eql(users.pluck(:id))

      ENV["TESTING_TAGS_FORMAT_USING"] = nil
    end
  end
end

def wait_for_tags_to_load(element, time = Capybara.default_max_wait_time)
  klass = "tagify--loading"
  Timeout.timeout(time) do
    sleep(0.05) while element[:class].to_s.include?(klass)
  end
end

def tags_element(parent)
  parent.find "tags.tagify"
end
