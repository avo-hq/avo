require 'rails_helper'

RSpec.describe 'HasAndBelongsToManyField', type: :system do
  let!(:user) { create :user }
  let!(:second_user) { create :user }
  let!(:project) { create :project }

  subject { visit url; page }

  context 'show' do
    let(:url) { "/avo/resources/projects/#{project.id}" }

    describe 'without a related user' do
      it { is_expected.to have_text 'No related users found' }

      it 'attaches a user' do
        visit url

        wait_for_loaded

        click_on 'Attach user'

        expect(page).to have_text 'Choose user'
        expect(page).to have_select 'options', selected: 'Choose an option'

        select user.name, from: 'options'

        expect {
          click_on 'Attach'
          wait_for_loaded
        }.to change(project.users, :count).by 1

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(page).not_to have_text 'Choose user'
        expect(page).not_to have_text 'No related users found'
      end

      it 'removes the modal' do
        visit url

        wait_for_loaded

        click_on 'Attach user'

        expect(page).to have_text 'Choose user'
        expect(page).to have_select 'options', selected: 'Choose an option'

        select user.name, from: 'options'

        expect {
          click_on 'Cancel'
          wait_for_loaded
        }.not_to change(project.users, :count)

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(page).not_to have_text 'Choose user'
        expect(page).to have_text 'No related users found'
      end

      it 'attaches two users' do
        visit url

        wait_for_loaded

        click_on 'Attach user'

        expect(page).to have_text 'Choose user'
        expect(page).to have_select 'options', selected: 'Choose an option'

        select user.name, from: 'options'

        expect {
          click_on 'Attach & Attach another'
          wait_for_loaded
        }.to change(project.users, :count).by 1

        expect(page).to have_text 'Choose user'
        expect(page).to have_select 'options', selected: 'Choose an option'

        select user.name, from: 'options'

        expect {
          click_on 'Attach'
          wait_for_loaded
        }.to change(project.users, :count).by 1

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(page).not_to have_text 'Choose user'
        expect(page).not_to have_text 'No related users found'
      end
    end

    describe 'with an attached user' do
      before do
        project.users << user
      end

      it 'detaches the user' do
        visit url

        wait_for_loaded

        expect(page).not_to have_text 'No related users found'

        find("[resource-name='users'][resource-id='#{user.id}'] [data-control='detach']").click

        expect(page).to have_text 'Are you sure?'

        expect {
          click_on 'Confirm'
          wait_for_loaded
        }.to change(project.users, :count).by -1

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(page).to have_text 'No related users found'
      end
    end
  end
end
