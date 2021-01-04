require_dependency 'avo/application_controller'

module Avo
  class ResourcesController < ApplicationController
    before_action :authorize_user

    def index
      @resources = User.all
    end
  end
end
