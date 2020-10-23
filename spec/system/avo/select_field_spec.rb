require 'rails_helper'
WebMock.disable_net_connect!(allow_localhost: true, allow: 'chromedriver.storage.googleapis.com')

RSpec.describe 'SelectField', type: :system do
  describe 'without a value' do
    let!(:project) { create :project, stage: nil }

    context 'show' do
      it 'displays the projects badge empty-dash' do
        visit "/avo/resources/projects/#{project.id}"

        expect(find_field_element(:stage)).to have_text empty_dash
        expect(find_field_element(:stage)).not_to have_css '.rounded-md'
      end
    end

    context 'edit' do
      it 'has the projects badge placeholder' do
        visit "/avo/resources/projects/#{project.id}/edit"

        expect(find_field_element(:stage)).to have_text 'Choose the stage.'
      end

      it 'changes the projects badge to info' do
        visit "/avo/resources/projects/#{project.id}/edit"

        select 'Romania', from: :country
        find("[field-id='stage'] [data-slot='value'] select").select 'Discovery'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(find_field_element(:stage)).to have_text 'DISCOVERY'
        expect(find_field_element(:stage)).to have_css '.rounded-md'
        expect(find_field_element(:stage)).to have_css '.bg-blue-500'
        expect(find_field_element(:stage)).not_to have_css '.bg-red-500'
      end

      it 'changes the projects badge to danger' do
        visit "/avo/resources/projects/#{project.id}/edit"

        select 'Romania', from: :country
        find("[field-id='stage'] [data-slot='value'] select").select 'Cancelled'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(find_field_element(:stage)).to have_text 'CANCELLED'
        expect(find_field_element(:stage)).to have_css '.rounded-md'
        expect(find_field_element(:stage)).to have_css '.bg-red-500'
        expect(find_field_element(:stage)).not_to have_css '.bg-blue-500'
      end
    end
  end
end
