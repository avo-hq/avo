require "rails_helper"

RSpec.feature "belongs_to", type: :feature do
  context "index" do
    describe "with a related user" do
      let!(:post) { create :post, user: admin }
    end
  end

  context "index" do
    let(:url) { "/admin/resources/posts?view_type=table" }

    subject do
      visit url
      find("[data-resource-id='#{post.id}'] [data-field-id='user']")
    end

    describe "with a related user" do
      let!(:post) { create :post, user: admin }

      it { is_expected.to have_text admin.name }
    end

    describe "without a related user" do
      let!(:post) { create :post }

      it { is_expected.to have_text empty_dash }
    end
  end

  subject do
    visit url
    find_field_value_element("user")
  end

  context "show" do
    let(:url) { "/admin/resources/posts/#{post.slug}" }

    describe "with user attached" do
      let!(:post) { create :post, user: admin }

      it { is_expected.to have_link admin.name, href: "/admin/resources/users/#{admin.slug}?via_resource_class=PostResource&via_resource_id=#{post.slug}" }
    end

    describe "without user attached" do
      let!(:post) { create :post }

      it { is_expected.to have_text empty_dash }
    end
  end

  context "edit" do
    let(:url) { "/admin/resources/posts/#{post.id}/edit" }

    describe "without user attached" do
      let!(:post) { create :post, user: nil }

      it { is_expected.to have_select "post_user_id", selected: nil, options: [empty_dash, admin.name] }

      it "changes the user" do
        visit url
        expect(page).to have_select "post_user_id", selected: nil, options: [empty_dash, admin.name]

        select admin.name, from: "post_user_id"

        click_on "Save"

        expect(current_path).to eql "/admin/resources/posts/#{post.slug}"
        expect(page).to have_link admin.name, href: "/admin/resources/users/#{admin.slug}?via_resource_class=PostResource&via_resource_id=#{post.slug}"
      end
    end

    describe "with user attached" do
      let!(:post) { create :post, user: admin }
      let!(:second_user) { create :user }

      it { is_expected.to have_select "post_user_id", selected: admin.name }

      it "changes the user" do
        visit url
        expect(page).to have_select "post_user_id", selected: admin.name

        select second_user.name, from: "post_user_id"

        click_on "Save"

        expect(current_path).to eql "/admin/resources/posts/#{post.slug}"
        expect(page).to have_link second_user.name, href: "/admin/resources/users/#{second_user.slug}?via_resource_class=PostResource&via_resource_id=#{post.slug}"
      end

      it "nullifies the user" do
        visit url
        expect(page).to have_select "post_user_id", selected: admin.name

        select empty_dash, from: "post_user_id"

        click_on "Save"

        expect(current_path).to eql "/admin/resources/posts/#{post.slug}"
        expect(find_field_value_element("user")).to have_text empty_dash
      end
    end
  end

  context "new" do
    let(:url) { "/admin/resources/posts/new?via_relation=user&via_relation_class=User&via_resource_id=#{admin.id}" }

    it { is_expected.to have_select "post_user_id", selected: admin.name, options: [empty_dash, admin.name], disabled: true }

    describe "with belongs_to foreign key field disabled" do
      let!(:course) { create :course }

      it "saves the related comment" do
        expect(Course::Link.count).to be 0

        visit "/admin/resources/course_links/new?via_relation=course&via_relation_class=Course&via_resource_id=#{course.id}"

        fill_in "course_link_link", with: "https://avo.cool"

        click_on "Save"
        wait_for_loaded

        # When the validation fails for any reason, the user is redirected to this weird `/new` path with the newly created model populating the form
        # This test is valid only as a system test. The feature test does not cover this edge-case
        expect(current_path).not_to eq "/admin/resources/course_links/new"
        expect(Course::Link.count).to be 1
        expect(Course::Link.first.course_id).to eq course.id
      end
    end
  end

  describe "hidden columns if current association" do
    let!(:user) { create :user, first_name: "Alicia" }
    let!(:comment) { create :comment, body: "a comment", user: user }

    it "hides the User column" do
      visit "/admin/resources/users/#{user.id}/comments?turbo_frame=has_many_field_show_comments"

      expect(find("thead")).to have_text "Id"
      expect(find("thead")).to have_text "Tiny name"
      expect(find("thead")).to have_text "Commentable"
      expect(find("thead")).not_to have_text "User"
      expect(page).to have_text comment.id
      expect(page).to have_text "a comment"
      expect(page).not_to have_text user.name
    end
  end

  describe "hidden columns if current polymorphic association" do
    let!(:user) { create :user }
    let!(:project) { create :project, name: "Haha project" }
    let!(:comment) { create :comment, body: "a comment", user: user, commentable: project }

    it "hides the Commentable column" do
      visit "/admin/resources/projects/#{project.id}/comments?turbo_frame=has_many_field_show_comments"

      expect(find("thead")).to have_text "Id"
      expect(find("thead")).to have_text "Tiny name"
      expect(find("thead")).to have_text "User"
      expect(find("thead")).not_to have_text "Commentable"
      expect(page).to have_text comment.id
      expect(page).to have_text "a comment"
      expect(page).to have_text user.name
      expect(page).not_to have_text project.name
    end
  end

  describe "hidden columns if current polymorphic association" do
    let!(:user) { create :user }
    let!(:team) { create :team, name: "Haha team" }
    let!(:review) { create :review, body: "a review", user: user, reviewable: team }

    it "hides the Reviewable column" do
      visit "/admin/resources/teams/#{team.id}/reviews?turbo_frame=has_many_field_show_reviews"

      expect(find("thead")).to have_text "Id"
      expect(find("thead")).to have_text "Excerpt"
      expect(find("thead")).to have_text "User"
      expect(find("thead")).not_to have_text "Reviewable"
      expect(page).to have_text review.id
      expect(page).to have_text "a review"
      expect(page).to have_text user.name
      expect(page).not_to have_text team.name
    end
  end
end
