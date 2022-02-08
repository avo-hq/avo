require "rails_helper"

RSpec.feature "belongs_to searchable", type: :system do
  let!(:amber) { create :user, first_name: 'Amber', last_name: 'Johnes' }
  let!(:alicia) { create :user, first_name: 'Alicia', last_name: 'Johnes' }
  let!(:post) { create :post, name: 'Avocados are the best' }

  before do
    # Update admin so it doesn't come up in the search
    admin.update(first_name: 'Jim', last_name: 'Johnes')
  end

  context 'new' do
    it 'searches for a user' do
      visit "/admin/resources/comments/new"

      expect(page).to have_field "comment_user_id"
      expect(page).to have_select "comment_commentable_type", selected: 'Choose an option', options: ['Choose an option', 'Post', 'Project']
      expect(page).to have_select "comment_commentable_id", selected: 'Choose an option', options: ['Choose an option', post.name], visible: false

      fill_in 'comment_body', with: 'Yup'
      select 'Post', from: 'comment_commentable_type'
      find('#comment_user_id').click

      write_in_search('A')

      sleep 0.5

      expect(find('.aa-Panel')).to have_content "Amber Johnes"
      expect(find('.aa-Panel')).to have_content "Alicia Johnes"

      write_in_search('Amber')

      sleep 0.5

      find(".aa-Input").send_keys :arrow_down
      find(".aa-Input").send_keys :return

      sleep 0.5

      text_input = find '[name="comment[user_id]"][type="text"]', visible: true
      expect(text_input.value).to eq 'Amber Johnes'

      click_on 'Save'

      wait_for_loaded

      comment = Comment.first

      expect(comment.user_id).to eq amber.id
    end

    context 'edit' do
      let!(:comment) { create :comment, body: 'Avo rules', commentable: post, user: amber }

      it 'changes the user' do
        visit "/admin/resources/comments/#{comment.id}/edit"

        expect(page).to have_field "comment_user_id", with: amber.name
        expect(page).to have_select "comment_commentable_type", selected: 'Post', options: ['Choose an option', 'Post', 'Project']
        expect(page).to have_select "comment_commentable_id", selected: post.name, options: ['Choose an option', post.name], visible: false

        fill_in 'comment_body', with: 'Avo rules!'
        find('#comment_user_id').click

        write_in_search('Alicia')

        sleep 0.5

        expect(find('.aa-Panel')).not_to have_content "Amber Johnes"
        expect(find('.aa-Panel')).to have_content "Alicia Johnes"

        find(".aa-Input").send_keys :arrow_down
        find(".aa-Input").send_keys :return

        sleep 0.5

        text_input = find '[name="comment[user_id]"][type="text"]', visible: true
        expect(text_input.value).to eq 'Alicia Johnes'

        click_on 'Save'

        wait_for_loaded

        comment.reload

        expect(comment.user_id).to eq alicia.id
        expect(comment.body).to eq 'Avo rules!'
      end

      it 'nullifies the user' do
        visit "/admin/resources/comments/#{comment.id}/edit"

        expect(page).to have_field "comment_user_id", with: amber.name
        expect(page).to have_select "comment_commentable_type", selected: 'Post', options: ['Choose an option', 'Post', 'Project']
        expect(page).to have_select "comment_commentable_id", selected: post.name, options: ['Choose an option', post.name], visible: false

        fill_in 'comment_body', with: 'Avo rules!'
        find('[data-action="click->search#clearValue"]').click
        expect(page).not_to have_selector '[data-action="click->search#clearValue"]'

        click_on 'Save'

        wait_for_loaded

        comment.reload

        expect(comment.user_id).to be nil
      end
    end
  end
end
