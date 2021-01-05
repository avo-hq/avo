require_dependency 'avo/application_controller'

module Avo
  class ResourcesController < ApplicationController
    before_action :authorize_user

    def index
      @resources = resource_model.all.map do |resource|
        Avo::Resources::Resource.hydrate_resource(model: resource, resource: avo_resource, view: :index, user: _current_user)
      end
    end

    def show
      model = resource_model.find params[:id]
      @resource = Avo::Resources::Resource.hydrate_resource(model: resource, resource: avo_resource, view: :show, user: _current_user)
    end
  end
end
