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

        expect(field_element_by_resource_id("tags", post.id)).to have_text empty_dash
      end

      it "shows filled state" do
        post.tag_list = ["some", "tags", "here", "and", "there"]
        post.save

        visit path

        field_element = field_element_by_resource_id("tags", post.id)

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

        click_on "Save"
        wait_for_loaded

        expect(post.reload.tag_list.sort).to eq ["1", "2"].sort
      end
    end
  end

  describe "ajax request" do
    let(:field_value_slot) { tags_element(find_field_value_element("user_id")) }
    let(:tags_input) { field_value_slot.find("span[contenteditable]") }
    let!(:zezel) { create :user, first_name: "Zezel", last_name: "Nunu" }
    let!(:users) { create_list :user, 15 }

    it "fetches the users" do
      expect(TestBuddy).to receive(:hi).with(zezel.id.to_s).at_least :once

      visit "/admin/resources/users/#{admin.slug}/actions/toggle_inactive"

      tags_input.click
      tags_input.set("Zezel")
      wait_for_tags_to_load(field_value_slot)
      tags_input.send_keys :arrow_down
      tags_input.send_keys :return

      sleep 0.3
      click_on "Run"
    end
  end

  describe "fetch labels" do
    let!(:users) { create_list :user, 2 }
    let!(:courses) { create_list :course, 2, skills: users.pluck(:id) }

    it "fetches the labels" do
      CourseResource.with_temporary_items do
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

      CourseResource.restore_items_from_backup
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
