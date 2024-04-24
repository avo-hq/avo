require_dependency "avo/application_controller"

module Avo
  class HomeController < ApplicationController
    def index
      if Avo.configuration.home_path.present?
        # If the home_path is a block run it, if not, just use it
        computed_path = if Avo.configuration.home_path.respond_to? :call
          instance_exec(&Avo.configuration.home_path)
        else
          Avo.configuration.home_path
        end

        redirect_to computed_path
      elsif !Rails.env.development?
        @page_title = "Get started"
        resource = Avo.resource_manager.all.min_by { |resource| resource.model_key }
        redirect_to resources_path(resource: resource)
      end
    end

    def failed_to_load
    end

    def lolo
      resource = Avo.resource_manager.get_resource(params[:resource_class])
      # abort resource.inspect
      @results = Avo::Services::SearchService.new(
        params:,
        authorization: @authorization,
        id_attribute: :value,
        label_attribute: :display,
        mark_labels: false
      ).search_resources([resource])[resource.route_key][:results].map do |item|
        item.slice(:display, :value)
        # item
      end
      # abort @results.inspect
      render turbo_stream: helpers.async_combobox_options(@results)
    end
  end
end
