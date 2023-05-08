# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Resource index map', type: :system do
  context 'when no resources are present' do
    it 'does not render the map' do
      visit '/admin/resources/cities?view_type=map'
      expect(page).to have_text('No record found')
    end
  end

  context 'when resources are present' do
    # Eiffel Tower coordinates used
    let!(:city) { create :city, latitude: 48.8584, longitude: 2.2945 }

    before do
      allow_any_instance_of(Avo::Index::ResourceMapComponent)
        .to(receive(:js_map).and_return('resource_index_map_content_here'))
    end

    it 'renders the map' do
      visit '/admin/resources/cities?view_type=map'
      expect(page).to have_text('resource_index_map_content_here')
    end
  end
end
