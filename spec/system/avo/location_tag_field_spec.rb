# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LocationTagField', type: :system do
  describe 'without value' do
    let!(:city) { create :city, coordinates: [] }
    context 'show' do
      it 'shows empty location field' do
        visit "/admin/resources/cities/#{city.id}"

        expect(find_field_element('coordinates')).to have_text empty_dash
      end
    end
    context 'edit' do
    end
  end

  describe 'with regular value' do
  end
end

def fill_in_trix_editor(id, with:)
  find("trix-editor[input='#{id}']").click.set(with)
end
