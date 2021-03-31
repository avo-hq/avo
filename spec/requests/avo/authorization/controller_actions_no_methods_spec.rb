# require 'rails_helper'

# class TeamPolicy < ApplicationPolicy
# end

# RSpec.describe 'TeamsController is_admin? policy', type: :request do
#   let(:user) { create :user }
#   let(:team) { create :team }

#   before do
#     login_as user
#   end

#   describe 'index?' do
#     subject { get '/avo/resources/teams' }

#     it 'fails' do
#       expect { subject }.to raise_error ActionController::RoutingError
#     end
#   end

#   describe '.new' do
#     subject { get '/avo/resources/teams/new' }

#     it 'fails' do
#       expect { subject }.to raise_error ActionController::RoutingError
#     end
#   end

#   describe 'create?' do
#     subject { post '/avo/resources/teams', params: { resource: { name: 'Avocado team' } } }

#     it 'fails' do
#       expect { subject }.to raise_error ActionController::RoutingError
#     end
#   end

#   describe 'show?' do
#     subject { get "/avo/resources/teams/#{team.id}" }

#     it 'fails' do
#       expect { subject }.to raise_error ActionController::RoutingError
#     end
#   end

#   describe 'update?' do
#     subject { put "/avo/resources/teams/#{team.id}", params: { team: { name: 'Avocado team' } } }

#     it 'fails' do
#       expect { subject }.to raise_error ActionController::RoutingError
#     end
#   end

#   describe 'edit?' do
#     subject { get "/avo/resources/teams/#{team.id}/edit" }

#     it 'fails' do
#       expect { subject }.to raise_error ActionController::RoutingError
#     end
#   end

#   describe 'destroy?' do
#     subject { delete "/avo/resources/teams/#{team.id}" }

#     it 'fails' do
#       expect { subject }.to raise_error ActionController::RoutingError
#     end
#   end
# end
