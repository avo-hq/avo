require 'rails_helper'

RSpec.feature Avo::SearchController, type: :controller do
  let!(:user) { create :user, first_name: 'John' }
  let!(:team) { create :team, name: 'Apple' }
  let!(:team_membership) { team.team_members << user }

  describe "global search" do
    it "does not return the ream membership" do
      get :index

      expect(json['users']['count']).to eq 1
      expect(json['users']['results'].first['_id']).to eq user.id
      expect(json.keys).to include "users"
      expect(json.keys).not_to include "team memberships"
    end
  end

  describe "resource search" do
    it "does not return the ream membership" do
      get :show, params: {
        resource_name: 'team_memberships'
      }

      expect(json.keys).not_to include "users"
      expect(json.keys).to include "team memberships"
      expect(json['team memberships']['count']).to eq 1
      expect(json['team memberships']['results'].first['_id']).to eq team.memberships.first.id
    end
  end
end
