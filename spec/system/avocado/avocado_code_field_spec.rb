require 'rails_helper'

RSpec.describe 'CodeField', type: :system do
  describe 'without value' do
    let!(:user) { create :user , custom_css: ''}

    context 'show' do
      it 'displays the projects empty code_snippet (dash)' do
        visit "/avocado/resources/users/#{user.id}"

        expect(find_field_value_element('custom_css')).to have_text empty_dash
      end
    end

    context 'edit' do
      it 'has the projects code_snippet label and empty code editor' do
        visit "/avocado/resources/users/#{user.id}/edit"

        custom_css_element = find_field_element('custom_css')

        expect(custom_css_element).to have_text 'Custom css'

        expect(custom_css_element).to have_css '.vue-codemirror'
      end
    end
  end
end
