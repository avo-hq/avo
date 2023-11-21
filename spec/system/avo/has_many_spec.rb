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

      it "shows the notification" do
        visit url

        expect {
          find("[data-resource-id='#{comments.first.id}'] [data-control='destroy']").click
          sleep 0.2
          confirm_alert
          sleep 0.2
          find("[data-resource-id='#{comments.third.id}'] [data-control='destroy']").click
          sleep 0.2
          confirm_alert
          sleep 0.2
        }.to change(Comment, :count).by(-2)

        expect(page).to have_current_path url

        expect(page).not_to have_text comments.first.tiny_name.to_s
        expect(page).not_to have_text comments.third.tiny_name.to_s
        expect(page).to have_text comments.second.tiny_name.to_s

        sleep 0.8
        expect(page).to have_text("Record destroyed").twice
      end

      it "shows the notification when delete fails" do
        Comment.class_eval do
          def destroy
            raise "Record failed to destroy"
          end
        end

        visit url

        expect {
          find("[data-resource-id='#{comments.first.id}'] [data-control='destroy']").click
          sleep 0.2
          page.driver.browser.switch_to.alert.accept
          sleep 0.2
          find("[data-resource-id='#{comments.third.id}'] [data-control='destroy']").click
          sleep 0.2
          page.driver.browser.switch_to.alert.accept
          sleep 0.2
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
end
