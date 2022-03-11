require 'rails_helper'

RSpec.describe 'Date field', type: :system do
  let!(:user) { create :user, birthday: Date.new(1988, 02, 10) }

  describe "in a western (negative) Timezone" do
    before do
      ENV['TZ'] = 'America/Chicago'
    end

    context 'edit' do
      it 'sets the proper date without the TZ modifications' do
        visit "/admin/resources/users/#{user.id}"

        click_on 'Edit'
        wait_for_loaded

        hidden_input = find '[data-controller="date-field"] input[type="hidden"]', visible: false
        text_input = find '[data-controller="date-field"] input[type="text"]'

        expect(hidden_input.value).to eq "1988-02-10"
        expect(text_input.value).to eq "February 10th 1988"
      end
    end
  end

  describe "in an eastern (positive) Timezone" do
    before do
      ENV['TZ'] = 'Europe/Bucharest'
    end

    context 'edit' do
      it 'sets the proper date without' do
        visit "/admin/resources/users/#{user.id}"

        click_on 'Edit'
        wait_for_loaded

        hidden_input = find '[data-controller="date-field"] input[type="hidden"]', visible: false
        text_input = find '[data-controller="date-field"] input[type="text"]'

        expect(hidden_input.value).to eq "1988-02-10"
        expect(text_input.value).to eq "February 10th 1988"
      end
    end
  end
end
