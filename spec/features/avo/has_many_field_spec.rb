require "rails_helper"

RSpec.feature "HasManyField", type: :feature do
  let!(:user) { create :user, first_name: "Alicia" }

  subject do
    visit url
    page
  end

  context "show" do
    # Test the frame directly
    let(:url) { "/admin/resources/users/#{user.slug}/posts?turbo_frame=has_many_field_posts&view_type=table" }

    describe "without a related post" do
      it { is_expected.to have_text "No related record found" }

      it "creates a post" do
        visit url

        click_on "Create new post"

        expect(page).to have_current_path "/admin/resources/posts/new?via_record_id=#{user.slug}&via_relation=user&via_relation_class=User&via_resource_class=Avo%3A%3AResources%3A%3AUser"
        expect(page).to have_select "post_user_id", selected: user.name, disabled: true

        fill_in "post_name", with: "New post name"

        save

        expect(current_path).to eql "/admin/resources/users/#{user.slug}"
        expect(user.posts.last.name).to eql "New post name"
        expect(user.posts.last.user_id).to eql user.id
      end
    end

    describe "with a related post" do
      let!(:post) { create :post, user: user }

      it "navigates to a view post page" do
        visit url

        click_on "Create new post"

        expect(page).to have_current_path "/admin/resources/posts/new?via_record_id=#{user.slug}&via_relation=user&via_relation_class=User&via_resource_class=Avo%3A%3AResources%3A%3AUser"
      end

      it "displays valid links to resources" do
        visit url

        # grid view button
        expect(page).to have_selector "[data-control='view-type-toggle-grid'][href='/admin/resources/users/#{user.slug}/posts?turbo_frame=has_many_field_posts&view_type=grid']"

        # create new button
        expect(page).to have_link("Create new post", href: "/admin/resources/posts/new?via_record_id=#{user.slug}&via_relation=user&via_relation_class=User&via_resource_class=Avo%3A%3AResources%3A%3AUser")

        # attach button
        expect(page).to have_link("Attach post", href: /\/admin\/resources\/users\/#{user.slug}\/posts\/new/)

        ## Table Rows
        # show link
        show_path = "/admin/resources/posts/#{post.slug}?via_record_id=#{user.slug}&via_resource_class=Avo%3A%3AResources%3A%3AUser"
        expect(page).to have_css("a[data-control='show'][href='#{show_path}']")

        # id field show link
        expect(field_element_by_resource_id("id", post.to_param)).to have_css("a[href='/admin/resources/posts/#{post.slug}?via_record_id=#{user.slug}&via_resource_class=Avo%3A%3AResources%3A%3AUser']")

        # edit link
        edit_path = "/admin/resources/posts/#{post.slug}/edit?via_record_id=#{user.slug}&via_resource_class=Avo%3A%3AResources%3A%3AUser"
        expect(page).to have_selector("[data-component-name='avo/ui/panel_component'] a[data-control='edit'][data-resource-id='#{post.to_param}'][href='#{edit_path}']")

        # detach link
        detach_path = "/admin/resources/users/#{user.slug}/posts/#{post.to_param}"
        expect(page).to have_selector("[data-component-name='avo/ui/panel_component'] a[data-control='detach'][data-turbo-method='delete'][href='#{detach_path}']")

        destroy_path = "/admin/resources/posts/#{post.slug}"
        destroy_link = find("[data-component-name='avo/ui/panel_component'] a[data-control='destroy'][data-target='control:destroy'][data-turbo-method='delete']")
        expect(destroy_link["href"]).to include(destroy_path)
      end
    end
  end

  describe "scope" do
    let!(:regular_comment) { create :comment, user: user, body: "Hey comment" }
    let!(:a_comment) { create :comment, user: user, body: "A comment that starts with the letter A" }

    subject do
      expect(TestBuddy).to receive(:hi).with("parent_resource:true,resource:true").at_least :once
      visit "/admin/resources/users/#{user.id}/comments?turbo_frame=has_many_field_show_comments"
      page
    end

    it { is_expected.to have_text "A comment that starts with the letter A" }
    it { is_expected.not_to have_text "Hey comment" }
  end

  describe "namespaced models" do
    let!(:course) { create :course }

    it "creates and updates the course" do
      expect(Course::Link.count).to be 0
      visit "/admin/resources/course_links/new?via_record_id=#{course.to_param}&via_relation=course&via_relation_class=Course"

      fill_in "course_link_link", with: "https://google.com"
      save

      link = Course::Link.last
      expect(Course::Link.count).to be 1
      expect(link.link).to eq "https://google.com"
      expect(link.course.id).to eq course.id

      visit "/admin/resources/course_links/#{link.id}/edit?via_resource_class=Avo::Resources::Course&via_record_id=#{course.to_param}"
      fill_in "course_link_link", with: "https://apple.com"
      save
      link.reload
      expect(link.link).to eq "https://apple.com"
      expect(link.course.id).to eq course.id
    end
  end

  describe "same model no resource" do
    let!(:person) { create :person }
    let!(:brother) { create :brother }

    it "does not raise an error" do
      expect {
        visit "/admin/resources/people"
      }.not_to raise_error
    end
  end

  describe "through relationship" do
    let!(:team) { create :team }
    let!(:user) { create :user }

    it "triggers callbacks on through model" do
      team.team_members << user
      expect(team.team_members.count).to eq 1

      visit "/admin/resources/teams/#{team.id}/team_members?view=show&turbo_frame=has_many_field_show_team_members"

      expect { find("tr[data-resource-id='#{user.to_param}'] [data-control='detach']").click }.to raise_error("Callback Called")
    end

    it "triggers callbacks when called from the other model too" do
      user.teams << team
      expect(user.teams.count).to eq 1

      visit "/admin/resources/users/#{user.to_param}/teams?view=show&turbo_frame=has_and_belongs_to_many_field_show_teams"

      expect { find("tr[data-resource-id='#{team.id}'] [data-control='detach']").click }.to raise_error("Callback Called")
    end
  end

  describe "dynamic description" do
    let(:url) { "/admin/resources/users/#{user.slug}/posts?turbo_frame=has_many_field_posts&view_type=table" }
    let!(:post_1) { create :post, user: user }
    let!(:post_2) { create :post, user: user }

    it { is_expected.to have_text "This user has 2 posts" }
  end

  describe "dynamic name" do
    let(:url) { "/admin/resources/users/#{user.slug}/posts?turbo_frame=has_many_field_posts&view_type=table" }

    it { is_expected.to have_text "Posts" }
  end

  describe "Hides items in views" do
    let!(:store) { create :store, size: "medium" }

    context "Visible filter button and search input" do
      it "shows the filter button when hide_filter_button is set to true" do
        Avo::Resources::Store.with_temporary_items do
          field :patrons, as: :has_many, through: :patronships
        end

        visit "/admin/resources/stores/#{store.id}/patrons"

        expect(page).to have_css('[data-component-name="avo/filters_component"]')
        expect(page).to have_css('[data-resource-search-target="input"]')

        Avo::Resources::Store.restore_items_from_backup
      end
    end

    context "Hides filter button and search input" do
      it "hides the filter button when hide_filter_button is set to true" do
        Avo::Resources::Store.with_temporary_items do
          field :patrons, as: :has_many, through: :patronships, hide_filter_button: true, hide_search_input: true
        end

        visit "/admin/resources/stores/#{store.id}/patrons"

        expect(page).not_to have_css('[data-component-name="avo/filters_component"]')
        expect(page).not_to have_css('[data-resource-search-target="input"]')

        Avo::Resources::Store.restore_items_from_backup
      end
    end
  end
end
