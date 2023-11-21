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

        click_on "Save"
        wait_for_loaded

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
        expect(page).to have_selector("[data-component='resources-index'] a[data-control='edit'][data-resource-id='#{post.id}'][href='#{edit_path}']")

        # detach form
        form = "form[action='/admin/resources/users/#{user.slug}/posts/#{post.id}']"
        expect(page).to have_selector("[data-component='resources-index'] #{form}")
        expect(page).to have_selector(:css, "#{form} input[type='hidden'][name='_method'][value='delete']", visible: false)
        # expect(page).to have_selector(:css, "#{form} input#referrer_detach_#{post.slug}[value='/admin/resources/users/#{user.slug}/posts?turbo_frame=has_many_field_posts']", visible: false)
        expect(page).to have_selector("[data-component='resources-index'] #{form} button[data-control='detach'][data-resource-id='#{post.id}'][data-turbo-frame='has_many_field_posts']")

        # destroy form
        form = "form[action='/admin/resources/posts/#{post.slug}']"
        expect(page).to have_selector("[data-component='resources-index'] #{form}")
        expect(page).to have_selector("#{form} input[type='hidden'][name='_method'][value='delete']", visible: false)
        # expect(page).to have_selector("#{form} input#referrer_destroy_#{post.id}[value='/admin/resources/users/#{user.slug}/posts?turbo_frame=has_many_field_posts']", visible: false)
        expect(page).to have_selector("[data-component='resources-index'] #{form} button[data-control='destroy'][data-resource-id='#{post.id}'][data-turbo-frame='has_many_field_posts']")
      end

      it "deletes a post" do
        visit url

        expect {
          find("[data-resource-id='#{post.to_param}'] [data-control='destroy']").click
        }.to change(Post, :count).by(-1)

        expect(page).to have_current_path url
        expect(page).not_to have_text post.name
      end

      it "detaches a post" do
        visit url

        expect {
          find("tr[data-resource-id='#{post.to_param}'] [data-control='detach']").click
        }.to change(user.posts, :count).by(-1)

        expect(page).to have_current_path url
        expect(page).not_to have_text post.name
      end
    end
  end

  describe "scope" do
    let!(:regular_comment) { create :comment, user: user, body: "Hey comment" }
    let!(:a_comment) { create :comment, user: user, body: "A comment that starts with the letter A" }

    subject do
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
      visit "/admin/resources/course_links/new?via_record_id=#{course.id}&via_relation=course&via_relation_class=Course"

      fill_in "course_link_link", with: "https://google.com"
      click_on "Save"

      link = Course::Link.last
      expect(Course::Link.count).to be 1
      expect(link.link).to eq "https://google.com"
      expect(link.course.id).to eq course.id

      visit "/admin/resources/course_links/#{link.id}/edit?via_resource_class=Avo::Resources::Course&via_record_id=#{course.id}"
      fill_in "course_link_link", with: "https://apple.com"
      click_on "Save"
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
end
