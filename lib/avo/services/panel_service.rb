module Avo
  module Services
    class PanelService
      attr_accessor :request
      attr_accessor :params
      attr_accessor :resource

      def initialize(request: nil, resource: nil)
        @request = request
        @params = request.params
      end

      def default_panel_name
        return @request[:via_relation_param].capitalize if @request[:via_relation_param] == "has_one"

        case @view
        when :show
          I18n.t("avo.resource_details", item: @resource.name.downcase, title: @resource.model_title).upcase_first
        when :edit
          I18n.t("avo.update_item", item: @resource.name.downcase, title: @resource.model_title).upcase_first
        when :new
          I18n.t("avo.create_new_item", item: @resource.name.downcase).upcase_first
        end
      end
    end
  end
end
