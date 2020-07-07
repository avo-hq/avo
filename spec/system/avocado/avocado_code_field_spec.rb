require 'rails_helper'

RSpec.describe 'CodeField', type: :system do
  describe 'without value' do
    let!(:project) { create :project , code_snippet: ''}

    context 'show' do
      it 'displays the projects empty code_snippet (dash)' do
        visit "/avocado/resources/projects/#{project.id}"

        expect(find_field_value_element('code_snippet')).to have_text empty_dash
      end
    end

    context 'edit' do
      it 'has the projects code_snippet label and empty code editor' do
        visit "/avocado/resources/projects/#{project.id}/edit"

        code_snippet_element = find_field_element('code_snippet')

        expect(code_snippet_element).to have_text 'Code snippet'

        expect(code_snippet_element).to have_css '.vue-codemirror'
      end
    end
  end
end
