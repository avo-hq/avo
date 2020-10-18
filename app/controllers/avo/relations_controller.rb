require_dependency 'avo/application_controller'

module Avo
  class RelationsController < ApplicationController
    before_action :authorize_user

    def attach
      attachment_class = App.get_model_class_by_name params[:attachment_name].pluralize 1
      attachment_model = attachment_class.safe_constantize.find params[:attachment_id]
      attached = resource.send(params[:attachment_name]) << attachment_model

      render json: {
        success: true,
        message: "#{attachment_class} attached.",
      }
    end

    def detach
      attachment_class = App.get_model_class_by_name params[:attachment_name].pluralize 1
      attachment_model = attachment_class.safe_constantize.find params[:attachment_id]
      attached = resource.send(params[:attachment_name]).delete attachment_model

      render json: {
        success: true,
        message: "#{attachment_class} attached.",
      }
    end
  end
end
