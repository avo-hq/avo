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
          visit "/admin/resources/posts/#{post.id}/comments?turbo_frame=has_many_field_show_comments"

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
      within("tr[data-record-id='#{user.id}']") do
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
          find("[data-resource-id='#{post.to_param}'] [data-control='destroy']").click
        end
      }.to change(Post, :count).by(-1)

      expect(page).to have_current_path url
      expect(page).not_to have_text post.name
    end
  end
end
