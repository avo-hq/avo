require 'rails_helper'

RSpec.describe 'CurrencyField', type: :system do
  describe 'without input' do
    let!(:project) { create :project, budget: nil }

    subject { visit url; find_field_element(:budget) }

    context 'index' do
      let!(:url) { '/avo/resources/projects' }

      it {
        is_expected.to have_text empty_dash
        is_expected.not_to have_css '.bg-transparent'
      }
    end

    context 'show' do
      let!(:url) { "/avo/resources/projects/#{project.id}" }

      it {
        is_expected.to have_text empty_dash
        is_expected.not_to have_css '.bg-transparent'
      }
    end

    context 'edit' do
      it 'has the projects budget prefilled' do
        visit "/avo/resources/projects/#{project.id}/edit"

        expect(find_field_element(:budget).find('input').value).to have_text ''
      end
    end
  end

  describe 'with input: budget = 1000' do
    let(:total_budget) { 1000 }

    let!(:project) { create :project, budget: total_budget }

    subject { visit url; find_field_element(:budget) }

    context 'index' do
      it 'displays the projects budget on index' do
        visit "/avo/resources/projects/#{project.id}"

        expect(find_field_element(:budget).find('input').value).to have_text '€1,000.00'
        expect(find_field_element(:budget)).to have_css '.bg-transparent'
      end
    end

    context 'show' do
      it 'displays the projects budget on show' do
        visit "/avo/resources/projects/#{project.id}"

        expect(find_field_element(:budget).find('input').value).to have_text '€1,000.00'
        expect(find_field_element(:budget)).to have_css '.bg-transparent'
      end
    end

    context 'edit' do
      it 'has the projects budget prefilled' do
        visit "/avo/resources/projects/#{project.id}/edit"

        expect(find_field_element(:budget).find('input').value).to have_text '€1,000.00'
      end

      it 'changes the projects budget using dot' do
        visit "/avo/resources/projects/#{project.id}/edit"

        fill_in 'budget', with: '100.1'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(find_field_element(:budget).find('input').value).to have_text '€100.10'
      end

      it 'changes the projects budget using comma' do
        visit "/avo/resources/projects/#{project.id}/edit"

        fill_in 'budget', with: '100,1'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avo/resources/projects/#{project.id}"
        expect(find_field_element(:budget).find('input').value).to have_text '€100.10'
      end
    end
  end
end
