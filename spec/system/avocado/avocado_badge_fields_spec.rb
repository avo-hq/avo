require 'rails_helper'

RSpec.describe 'BadgeField', type: :system do
  let!(:project) { create :project, condition: 'info' }

  context 'index' do
    it 'displays the projects condition' do
      visit '/avocado/resources/projects'

      expect(find_field_element('condition')).to have_text 'INFO'
      expect(find_field_element('condition')).to have_css '.rounded-full'
      expect(find_field_element('condition')).to have_css '.bg-blue-500'
      expect(find_field_element('condition')).to have_css '.uppercase'
      expect(find_field_element('condition')).to have_css '.font-bold'
      expect(find_field_element('condition')).to have_css '.text-white'
    end
  end

  context 'show' do
    it 'displays the projects condition' do
      visit "/avocado/resources/projects/#{project.id}"

      expect(find_field_element('condition')).to have_text 'INFO'
      expect(find_field_element('condition')).to have_css '.rounded-full'
      expect(find_field_element('condition')).to have_css '.bg-blue-500'
      expect(find_field_element('condition')).to have_css '.uppercase'
      expect(find_field_element('condition')).to have_css '.font-bold'
      expect(find_field_element('condition')).to have_css '.text-white'
    end
  end
end
