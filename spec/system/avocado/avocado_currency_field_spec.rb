require 'rails_helper'

RSpec.describe 'CurrencyField', type: :system do
  describe 'without input' do
    let!(:user) { create :user, salary: nil }

    subject { visit url; find_field_element(:salary) }

    context 'index' do
      let!(:url) { '/avocado/resources/users' }

      it {
        is_expected.to have_text empty_dash
        is_expected.not_to have_css '.bg-transparent'
      }
    end

    context 'show' do
      let!(:url) { "/avocado/resources/users/#{user.id}" }

      it {
        is_expected.to have_text empty_dash
        is_expected.not_to have_css '.bg-transparent'
      }
    end

    context 'edit' do
      it 'has the users salary prefilled' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find_field_element(:salary).find('input').value).to have_text '€0.00'
      end
    end
  end

  describe 'with input: salary = 1000' do
    let(:monthly_salary) { 1000 }

    let!(:user) { create :user, salary: monthly_salary }

    subject { visit url; find_field_element(:salary) }

    context 'index' do
      it 'displays the users salary on index' do
        visit "/avocado/resources/users/#{user.id}"

        expect(find_field_element(:salary).find('input').value).to have_text '€1,000.00'
        expect(find_field_element(:salary)).to have_css '.bg-transparent'
      end
    end

    context 'show' do
      it 'displays the users salary on show' do
        visit "/avocado/resources/users/#{user.id}"

        expect(find_field_element(:salary).find('input').value).to have_text '€1,000.00'
        expect(find_field_element(:salary)).to have_css '.bg-transparent'
      end
    end

    context 'edit' do
      it 'has the users salary prefilled' do
        visit "/avocado/resources/users/#{user.id}/edit"

        expect(find_field_element(:salary).find('input').value).to have_text '€1,000.00'
      end

      it 'changes the users salary using dot' do
        visit "/avocado/resources/users/#{user.id}/edit"

        fill_in 'salary', with: '100.1'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/users/#{user.id}"
        expect(find_field_element(:salary).find('input').value).to have_text '€100.10'
      end

      it 'changes the users salary using comma' do
        visit "/avocado/resources/users/#{user.id}/edit"

        fill_in 'salary', with: '100,1'

        click_on 'Save'
        wait_for_loaded

        expect(current_path).to eql "/avocado/resources/users/#{user.id}"
        expect(find_field_element(:salary).find('input').value).to have_text '€100.10'
      end
    end
  end
end
