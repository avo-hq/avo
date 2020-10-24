require 'rails_helper'

RSpec.describe Avo::ResourceOverviewController, type: :controller do
  before :each do
    stub_pro_license_request
  end

  context 'configs' do
    describe 'with false values' do
      it 'returns false values' do
        get :index

        expect(response).to have_http_status(200)

        expect(parsed_response['hidden']).to be false
        expect(parsed_response['hide_docs']).to be false
      end
    end

    describe 'with true values' do
      around do |spec|
        Avo.configuration.hide_resource_overview_component = true
        Avo.configuration.hide_documentation_link = true

        spec.run

        Avo.configuration.hide_resource_overview_component = false
        Avo.configuration.hide_documentation_link = false
      end

      it 'returns true values' do
        get :index

        expect(response).to have_http_status(200)

        expect(parsed_response['hidden']).to be true
        expect(parsed_response['hide_docs']).to be true
      end
    end
  end

  describe 'without any resources in the DB' do
    it 'returns empty response' do
      get :index

      expect(response).to have_http_status(200)

      expect(parsed_response['hidden']).to be false
      expect(parsed_response['hide_docs']).to be false
      expect(parsed_response['resources']).to match_array([
        {
          count: 0,
          name: 'Team',
          url: 'teams',
        },
        {
          count: 0,
          name: 'Project',
          url: 'projects',
        },
        {
          count: 0,
          name: 'Post',
          url: 'posts',
        },
        {
          count: 0,
          name: 'Team Membership',
          url: 'team_memberships',
        },
        {
          count: 0,
          name: 'User',
          url: 'users',
        },
      ].map(&:deep_stringify_keys))
    end
  end

  describe 'with some resources in the DB' do
    before do
      create_list :user, 3
      create_list :team, 2
    end

    it 'returns non-empty response' do
      get :index

      expect(response).to have_http_status(200)

      expect(parsed_response['hidden']).to be false
      expect(parsed_response['hide_docs']).to be false
      expect(parsed_response['resources']).to match_array([
        {
          count: 2,
          name: 'Team',
          url: 'teams',
        },
        {
          count: 0,
          name: 'Project',
          url: 'projects',
        },
        {
          count: 0,
          name: 'Post',
          url: 'posts',
        },
        {
          count: 0,
          name: 'Team Membership',
          url: 'team_memberships',
        },
        {
          count: 3,
          name: 'User',
          url: 'users',
        },
      ].map(&:deep_stringify_keys))
    end
  end
end
