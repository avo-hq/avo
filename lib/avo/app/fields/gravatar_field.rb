require 'digest'
require 'erb'

module Avo
  module Fields
    class GravatarField < Field
      def initialize(name, **args, &block)
        @defaults = {
          component: 'gravatar-field',
          name: 'Avatar',
          id: args[:id].present? ? args[:id] : 'email',
        }

        super(name, **args, &block)

        hide_on [:edit, :create]

        @rounded = args[:rounded].present? ? args[:rounded] : true
        @size = args[:size].present? ? args[:size].to_i : 40
        @default = args[:default].present? ? ERB::Util.url_encode(args[:default]).to_s : ''
        @link_to_resource = args[:link_to_resource].present? ? args[:link_to_resource] : false
      end

      def hydrate_field(fields, model, resource, view)
        value = nil

        if model[id].present?
          value = Digest::MD5.hexdigest(model[id].strip.downcase)
        end

        {
          value: value,
          rounded: @rounded,
          default: @default,
          size: @size,
          link_to_resource: @link_to_resource,
        }
      end
    end
  end
end
