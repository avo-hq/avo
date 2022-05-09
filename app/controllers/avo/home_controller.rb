require_dependency "avo/application_controller"

module Avo
  class HomeController < ApplicationController
    def index
      if Avo.configuration.home_path.present?
        redirect_to Avo.configuration.home_path
      elsif !Rails.env.development?
        @page_title = "Get started"
        resource = Avo::App.resources.min_by { |resource| resource.model_key }
        redirect_to resources_path(resource: resource)
      end
    end

    def hey
      t = ResourceChannel.broadcast_to "bestd:1", body: "This Room is Best Room."
      # puts ["in hey->", t].inspect
      render plain: "ok"
      # Turbo::StreamsChannel.broadcast_replace_to "resource:1:1", target: "hehe" do
      #   'something'
      # end

        # render turbo_stream: turbo_stream.replace('hehe', 'hoho')
        # format.html         { redirect_to messages_url }
      # end
    end

    def failed_to_load
    end
  end
end
