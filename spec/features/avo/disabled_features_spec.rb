require "rails_helper"

RSpec.describe "badge", type: :feature do
  describe 'global_search' do
    context 'without it disabled' do
      it 'displayes the search bar' do
        visit '/admin/resources/people'

        expect(page).to have_selector('[data-controller="search"]')
      end
    end

    context 'with it disabled' do
      before do
        Avo.configure do |config|
          config.disabled_features = [:global_search]
        end
      end

      after do
        Avo.configure do |config|
          config.disabled_features = []
        end
      end

      it 'displayes the search bar' do
        visit '/admin/resources/people'

        expect(page).not_to have_selector('[data-controller="search"]')
      end
    end
  end
end
