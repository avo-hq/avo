require_dependency 'avo/application_controller'

module Avo
  class ResourceOverviewController < ApplicationController
    def index
      resources = App.get_resources
        .select { |resource| AuthorizationService::authorize session_user, resource.model, Avo.configuration.authorization_methods.stringify_keys['index'] }
        .map do |resource|
          {
            name: resource.name,
            url: resource.url,
            count: resource.model.count,
          }
        end

      render json: {
        resources: resources,
        hidden: Avo.configuration.hide_resource_overview_component,
        hide_docs: Avo.configuration.hide_documentation_link,
      }
    end

    private
      def session_user
        current_user.present? ? current_user : nil
      end
  end
end
