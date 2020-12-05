require 'rails_helper'

RSpec.describe 'HasManyField', type: :system do
  let!(:user) { create :user }
  let!(:project) { create :project }

  subject { visit url; page }

  context 'show' do
    let(:url) { "/avo/resources/users/#{user.id}" }

    describe 'without a related project' do
      it 'attaches a project' do
        visit url

        wait_for_loaded

        click_on 'Attach project'

        expect(page).to have_text 'Choose project'

        select project.name, from: 'options'

        click_on 'Attach'
        wait_for_loaded

        expect(page).to have_text 'Project attached'
        expect(page).not_to have_text 'Choose project'
        expect(page).to have_text project.name

        expect(user.projects.pluck('id')).to include project.id
      end
    end
  end

  context 'show' do
    let(:url) { "/avo/resources/users/#{user.id}" }

    describe 'with a related project' do
      it 'detaches the project' do
        user.projects << project

        visit url
        wait_for_loaded

        find("tr[resource-id='#{project.id}'] a[data-control='detach']").click

        expect(page).to have_text 'Detach project'

        click_on 'Confirm'
        wait_for_loaded

        expect(page).not_to have_text project.name
      end
    end
  end
end
