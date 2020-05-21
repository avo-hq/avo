require 'rails_helper'

RSpec.feature "ResourcesControllers", type: :feature do

  before do
    # driven_by :headless_chrome
  end
  it 'returns true' do
    expect(true).to be true
  end

  describe '#index' do
    it 'returns the resources' do

    end
  end
end
