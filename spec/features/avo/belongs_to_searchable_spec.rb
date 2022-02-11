require "rails_helper"

RSpec.feature "belongs_to searchable", type: :system do
  let!(:amber) { create :user, first_name: 'Amber', last_name: 'Johnes' }
  let!(:alicia) { create :user, first_name: 'Alicia', last_name: 'Johnes' }
  let!(:post) { create :post, name: 'Avocados are the best' }
  let!(:team) { create :team, name: 'Apple' }
  let!(:second_post) { create :post, name: 'Artichokes are good too' }

  before do
    # Update admin so it doesn't come up in the search
    admin.update(first_name: 'Jim', last_name: 'Johnes')
  end

  context 'new' do
    it 'searches for a user' do
      visit "/admin/resources/reviews/new"

      expect(page).to have_field "review_user_id"
      expect(page).to have_select "review_reviewable_type", selected: 'Choose an option', options: ['Choose an option', 'Fish', 'Post', 'Project', 'Team']

      select 'Post', from: 'review_reviewable_type'

      expect(page).to have_field "review_reviewable", placeholder: 'Choose an option'

      fill_in 'review_body', with: 'Yup'
      find('#review_reviewable').click

      write_in_search('A')

      sleep 0.5

      expect(find('.aa-Panel')).to have_content "Avocados"
      expect(find('.aa-Panel')).to have_content "Artichokes"
      expect(find('.aa-Panel')).not_to have_content "TEAMS"

      write_in_search('Avocado')

      sleep 0.5

      find(".aa-Input").send_keys :arrow_down
      find(".aa-Input").send_keys :return

      sleep 0.5

      text_input = find '[name="review[reviewable]"][type="text"]', visible: true
      expect(text_input.value).to eq 'Avocados are the best'

      click_on 'Save'

      wait_for_loaded

      review = Review.first

      expect(review.reviewable).to eq post
    end

    context 'edit' do
      let!(:review) { create :review, body: 'Avo rules', reviewable: post, user: amber }

      context 'belongs_to' do
        it 'prefills the searchable belongs_to field' do
          visit "/admin/resources/reviews/#{review.id}/edit"

          text_field = find '#review_user_id[type="text"]'
          hidden_field = find '#review_user_id[type="hidden"]', visible: false

          expect(text_field.value).to eq amber.name
          expect(hidden_field.value).to eq amber.id.to_s
        end
      end

      context 'belongs_to polymorphic' do
        it 'changes the reviewable item' do
          visit "/admin/resources/reviews/#{review.id}/edit"

          expect(page).to have_field "review_reviewable", with: post.name
          expect(page).to have_select "review_reviewable_type", selected: 'Post', options: ['Choose an option', 'Fish', 'Post', 'Project', 'Team']
          expect(page).to have_field type: 'text', name: "review[reviewable]", with: post.name
          expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: post.id, visible: false

          fill_in 'review_body', with: 'Avo rules!'
          find('#review_reviewable').click

          write_in_search('Artichokes')

          sleep 0.5

          expect(find('.aa-Panel')).not_to have_content "Avocados"
          expect(find('.aa-Panel')).to have_content "Artichokes"

          find(".aa-Input").send_keys :arrow_down
          find(".aa-Input").send_keys :return

          sleep 0.5

          expect(page).to have_field type: 'text', name: "review[reviewable]", with: second_post.name
          expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: second_post.id, visible: false

          click_on 'Save'

          wait_for_loaded

          review.reload

          expect(review.reviewable).to eq second_post
          expect(review.body).to eq 'Avo rules!'
        end
      end

      it 'nullifies the reviewable item' do
        visit "/admin/resources/reviews/#{review.id}/edit"

        expect(page).to have_field "review_reviewable", with: post.name
        expect(page).to have_select "review_reviewable_type", selected: 'Post', options: ['Choose an option', 'Fish', 'Post', 'Project', 'Team']
        expect(page).to have_field type: 'text', name: "review[reviewable]", with: post.name
        expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: post.id, visible: false

        fill_in 'review_body', with: 'Avo rules!'
        find('[data-type="Post"] [data-field-id="reviewable"] [data-action="click->search#clearValue"]').click
        expect(find('[data-type="Post"] [data-field-id="reviewable"]', visible: true)).not_to have_selector '[data-action="click->search#clearValue"]'

        click_on 'Save'

        wait_for_loaded

        review.reload

        expect(review.reviewable).to be nil
      end

      it 'toggles the reviewable item' do
        visit "/admin/resources/reviews/#{review.id}/edit"

        expect(page).to have_field "review_reviewable", with: post.name
        expect(page).to have_select "review_reviewable_type", selected: 'Post', options: ['Choose an option', 'Fish', 'Post', 'Project', 'Team']
        expect(page).to have_field type: 'text', name: "review[reviewable]", with: post.name
        expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: post.id, visible: false

        # Change reviewable to Team and check for empty inputs
        select 'Team', from: 'review_reviewable_type'

        expect(page).to have_field type: 'text', name: "review[reviewable]", with: ''
        expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: '', visible: false

        find('#review_reviewable').click
        write_in_search('Apple')

        sleep 0.5

        expect(find('.aa-Panel')).to have_content "Apple"

        find(".aa-Input").send_keys :arrow_down
        find(".aa-Input").send_keys :return

        sleep 0.5

        expect(page).to have_field type: 'text', name: "review[reviewable]", with: 'Apple'
        expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: team.id, visible: false

        # Change reviewable to Fish and check for empty inputs
        select 'Fish', from: 'review_reviewable_type'

        expect(page).to have_field type: 'text', name: "review[reviewable]", with: ''
        expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: '', visible: false

        # Change reviewable to Post and check for inputs filled with the post details
        select 'Post', from: 'review_reviewable_type'

        expect(page).to have_field type: 'text', name: "review[reviewable]", with: post.name
        expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: post.id, visible: false

        # Change reviewable to Team and check for inputs filled with the team details
        select 'Team', from: 'review_reviewable_type'

        expect(page).to have_field type: 'text', name: "review[reviewable]", with: 'Apple'
        expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: team.id, visible: false

        click_on 'Save'

        wait_for_loaded

        review.reload

        expect(review.reviewable).to eq team
      end

      it 'nullifies the reviewable type' do
        visit "/admin/resources/reviews/#{review.id}/edit"

        expect(page).to have_field "review_reviewable", with: post.name
        expect(page).to have_select "review_reviewable_type", selected: 'Post', options: ['Choose an option', 'Fish', 'Post', 'Project', 'Team']
        expect(page).to have_field type: 'text', name: "review[reviewable]", with: post.name
        expect(page).to have_field type: 'hidden', name: "review[reviewable_id]", with: post.id, visible: false

        select 'Choose an option', from: 'review_reviewable_type'

        click_on 'Save'

        wait_for_loaded

        review.reload

        expect(review.reviewable).to be nil
      end
    end
  end
end
