require "rails_helper"

RSpec.feature "HasManyField", type: :system do
  let!(:user) { create :user }

  context "show" do
    context "posts -> comments" do
      # Fixes https://github.com/avo-hq/avo/issues/668
      describe "displays has other association fields" do
        let!(:post) { create :post }
        let!(:comment) { create :comment, commentable: post, user: user }

        it "displays the other fields" do
          visit "/admin/resources/posts/#{post.to_param}/comments?turbo_frame=has_many_field_show_comments"

          row = find("[data-resource-name='comments'][data-resource-id='#{comment.id}']")

          expect(row.find('[data-field-id="user"]').text).to eq user.name
        end
      end
    end

    context "team -> reviews" do
      # Fixes https://github.com/avo-hq/avo/issues/668
      describe "displays has other association fields" do
        let!(:team) { create :team }
        let!(:review) { create :review, reviewable: team, user: user }

        it "displays the other fields" do
          visit "/admin/resources/teams/#{team.id}/reviews?turbo_frame=has_many_field_show_reviews"

          row = find("[data-resource-name='reviews'][data-resource-id='#{review.id}']")

          expect(row.find('[data-field-id="user"]').text).to eq user.name
        end
      end
    end

    context "team -> team_members and admins" do
      let!(:team) { create :team }
      let!(:member) { create :user, first_name: "Marta", last_name: "Member" }
      let!(:first_admin) { create :user, first_name: "Anders", last_name: "Admin" }
      let!(:second_admin) { create :user, first_name: "Berit", last_name: "Boss" }
      let(:team_members_frame) { 'turbo-frame[id="has_many_field_show_team_members"]' }
      let(:admins_frame) { 'turbo-frame[id="has_many_field_show_admins"]' }

      before do
        TeamMembership.create!(team: team, user: member, level: :member)
        TeamMembership.create!(team: team, user: first_admin, level: :admin)
        TeamMembership.create!(team: team, user: second_admin, level: :admin)

        visit avo.resources_team_path(team)

        scroll_to find(admins_frame)
        within(team_members_frame) { expect(page).to have_text "Marta" }
        within(admins_frame) { expect(page).to have_text "Anders" }
      end

      it "searches one panel without replacing the other panel showing the same resource" do
        within(admins_frame) do
          find("[data-resource-search-target='input']").set("Berit")
          expect(page).to have_text "Berit"
          expect(page).not_to have_text "Anders"
        end

        within(team_members_frame) do
          expect(page).to have_text "Marta"
          expect(page).to have_text "Anders"
          expect(page).to have_text "Berit"
        end
      end

      it "runs an action on the rows selected in its own panel only" do
        project = create :project, users: [member, first_admin, second_admin]

        within(team_members_frame) { find("#{row(member.to_param)} input[type=checkbox]").click }
        within(admins_frame) { find("#{row(second_admin.to_param)} input[type=checkbox]").click }

        open_action(action_name: "Detach User", list: "Actions", context: find("#{admins_frame} .header__controls"))
        run_action

        expect(project.reload.users).to contain_exactly(member, first_admin)
      end
    end

    context "project -> even_reviews and reviews" do
      let!(:project) { create :project }
      let!(:reviews) { create_list :review, 2, reviewable: project }
      let(:even_review) { reviews.find { |review| review.id.even? } }
      let(:odd_review) { reviews.find { |review| review.id.odd? } }

      it "searches a for_attribute panel independently of the panel for the same association" do
        visit avo.resources_project_path(project)

        even_reviews_frame = 'turbo-frame[id="has_many_field_show_even_reviews"]'
        reviews_frame = 'turbo-frame[id="has_many_field_show_reviews"]'
        scroll_to find(reviews_frame)
        within(even_reviews_frame) { expect(page).to have_selector row(even_review.id) }
        within(reviews_frame) { expect(page).to have_selector row(even_review.id) }

        within(reviews_frame) do
          find("[data-resource-search-target='input']").set(odd_review.id)
          expect(page).to have_selector row(odd_review.id)
          expect(page).not_to have_selector row(even_review.id)
        end

        within(even_reviews_frame) do
          expect(page).to have_selector row(even_review.id)
          expect(page).not_to have_selector row(odd_review.id)
        end
      end
    end

    describe "delete notification visible" do
      let!(:project) { create :project }
      let!(:comments) { create_list :comment, 3, commentable: project }
      let(:url) { "/admin/resources/projects/#{project.id}" }

      # TODO: refactor this test as it's very flaky
      # it "shows the notification" do
      #   visit url

      #   scroll_to find('turbo-frame[id="has_many_field_show_comments"]')

      #   expect {
      #     accept_custom_alert do
      #       find("[data-resource-id='#{comments.first.id}'] [data-control='destroy']").click
      #     end

      #     accept_custom_alert do
      #       find("[data-resource-id='#{comments.third.id}'] [data-control='destroy']").click
      #     end
      #   }.to change(Comment, :count).by(-2)

      #   expect(page).to have_current_path url

      #   expect(page).not_to have_text comments.first.tiny_name.to_s
      #   expect(page).not_to have_text comments.third.tiny_name.to_s
      #   expect(page).to have_text comments.second.tiny_name.to_s

      #   sleep 0.8
      #   expect(page).to have_text("Record destroyed").twice
      # end

      it "shows the notification when delete fails" do
        Comment.class_eval do
          def destroy
            raise "Record failed to destroy"
          end
        end

        visit url

        scroll_to find('turbo-frame[id="has_many_field_show_comments"]')

        expect {
          accept_custom_alert do
            find("[data-resource-id='#{comments.first.id}'] [data-control='destroy']").click
          end

          accept_custom_alert do
            find("[data-resource-id='#{comments.third.id}'] [data-control='destroy']").click
          end
        }.to change(Comment, :count).by(0)

        expect(page).to have_current_path url

        expect(page).to have_text comments.third.tiny_name.to_s
        expect(page).to have_text comments.first.tiny_name.to_s
        expect(page).to have_text comments.second.tiny_name.to_s

        sleep 0.8
        expect(page).to have_text("Record failed to destroy").twice
      ensure
        Comment.class_eval do
          def destroy
            super
          end
        end
      end
    end
  end

  describe "duplicated field id" do
    let!(:store) { create(:store) }

    it "render tags and has many field" do
      StorePatron.create!(user:, store:, review: "some review")
      visit avo.resources_store_path(store)

      # Find user name on tags field
      expect(page).to have_css('div[data-field-id="patrons"] div[data-target="tag-component"]', text: user.name)

      # Find user name on has many field
      within("tr[data-record-id='#{user.to_param}']") do
        expect(page).to have_text(user.first_name)
        expect(page).to have_text(user.last_name)
      end
    end
  end

  describe "with a related post" do
    let!(:post) { create :post, user: user }
    let!(:url) { "/admin/resources/users/#{user.slug}?tab-group_second_tabs_group=Posts" }

    it "deletes a post" do
      visit url

      scroll_to find('turbo-frame[id="has_many_field_show_posts"]')

      expect {
        accept_custom_alert do
          click_row_action(post, control: :destroy)
        end
      }.to change(Post, :count).by(-1)

      expect(page).to have_current_path url
      expect(page).not_to have_text post.name
    end

    it "detaches a post" do
      visit url

      scroll_to find('turbo-frame[id="has_many_field_show_posts"]')

      expect {
        accept_custom_alert do
          click_row_action(post, control: :detach)
        end
      }.to change(user.posts, :count).by(-1)

      expect(page).to have_current_path url
      expect(page).not_to have_text post.name
    end
  end
end
