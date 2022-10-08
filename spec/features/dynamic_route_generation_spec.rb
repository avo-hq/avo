# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'dynamic route generation', type: :feature do
  let(:admin_user) { create :user, roles: { 'admin': true } }

  before do
    login_as admin_user
  end

  it 'defines routes for resources' do
    expect { visit '/admin/resources/fish' }.not_to raise_error
  end
end
