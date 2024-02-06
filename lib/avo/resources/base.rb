module Avo
  module Resources
    class Base
      include Avo::Concerns::HasResourceStimulusControllers
      include Avo::Concerns::HasDescription
      include Avo::Concerns::HasControls

      class_attribute :authorization_policy
      class_attribute :visible_on_sidebar, default: true
      class_attribute :components, default: {}
      class_attribute :search, default: {}
      class_attribute :view_types
      class_attribute :grid_view
      class_attribute :map_view

      attr_accessor :view

      delegate :plural_name,
        :singular_name,
        :singular_route_key,
        :is_active_record_resource?,
        :is_http_resource?,
        to: :class

      class << self
        alias_method :singular_name, :name

        delegate :t, to: ::I18n

        def class_name
          to_s.demodulize
        end

        def route_key
          class_name.underscore.pluralize
        end

        def singular_route_key
          route_key.singularize
        end

        def translation_key
          @translation_key || "avo.resource_translations.#{class_name.underscore}"
        end

        def name
          default = class_name.underscore.humanize

          if translation_key
            t(translation_key, count: 1, default: default).humanize
          else
            default
          end
        end

        def plural_name
          default = name.pluralize

          if translation_key
            t(translation_key, count: 2, default: default).humanize
          else
            default
          end
        end

        def navigation_label
          plural_name.humanize
        end

        # def is_active_record_resource? / def is_http_resource?
        [:active_record, :http].each do |resource_type|
          define_method "is_#{resource_type}_resource?" do
            ancestors.include? "Avo::Resources::#{resource_type.to_s.camelize}".constantize
          end
        end

        def search_query
          search.dig(:query)
        end
      end

      def available_view_types
        if self.class.view_types.present?
          return Array(
            Avo::ExecutionContext.new(
              target: self.class.view_types,
              resource: self,
              record: record
            ).handle
          )
        end

        view_types = [:table]

        view_types << :grid if self.class.grid_view.present?
        view_types << :map if map_view.present?

        view_types
      end
    end
  end
end
