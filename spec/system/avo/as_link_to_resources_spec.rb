require 'rails_helper'

RSpec.describe 'AsLinkToResources', type: :system do
  describe 'for id field' do
    let!(:project) { create :project}

    context 'index' do
      it 'displays the projects id as link' do
        visit '/avo/resources/projects'

        expect(find_field_element('id')).to have_selector 'a[title="View Project"]'
      end

      it 'clicks on the projects id' do
        visit '/avo/resources/projects'

        find('[field-id="id"]').find('a').click
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
      end
    end
  end

  describe 'for text field' do
    let!(:user) { create :user, first_name: 'Relu' }

    context 'index' do
      it 'displays the user first name as link' do
        visit '/avo/resources/users'

        expect(find_field_element('first_name')).to have_text 'Relu'
        expect(find_field_element('first_name')).to have_selector 'a[title="View User"]'
      end

      it 'clicks on the user first name' do
        visit '/avo/resources/users'

        find('[field-id="first_name"]').find('a').click
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/users/#{user.id}"
      end
    end
  end
end
