require 'rails_helper'

RSpec.describe "StatusFields", type: :system do
  describe 'with regular input' do
    let!(:project) { create :project }

    context 'index' do
      it 'displays the projects status' do
        visit '/avocado/resources/projects'

        expect(page).to have_text project.status
      end
    end

    context 'show' do
      it 'displays the projects status' do
        visit "/avocado/resources/projects/#{project.id}"

        expect(page).to have_text project.status
      end
    end

    context 'edit' do
      it 'has the projects status prefilled' do
        visit "/avocado/resources/projects/#{project.id}/edit"

        expect(find_field('status').value).to eq ''
      end

      it 'changes the projects status to normal' do
        visit "/avocado/resources/projects/#{project.id}/edit"

        fill_in 'status', with: 'normal'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/projects/#{project.id}"
        expect(page).to have_text 'normal'
      end

      it 'changes the projects status to failed' do
        visit "/avocado/resources/projects/#{project.id}/edit"

        fill_in 'status', with: 'failed'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/projects/#{project.id}"
        expect(page).to have_text 'failed'
      end

      it 'changes the projects status to waiting' do
        visit "/avocado/resources/projects/#{project.id}/edit"

        fill_in 'status', with: 'waiting'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/projects/#{project.id}"
        expect(page).to have_text 'waiting'
      end

    end
  end
end
