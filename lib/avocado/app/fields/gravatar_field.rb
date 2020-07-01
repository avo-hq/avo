require_relative 'field'
require 'digest'
require 'erb'

module Avocado
  module Fields
    class GravatarField < Field
      def initialize(name, **args, &block)
        @defaults = {
          component: 'gravatar-field',
          name: 'Avatar',
          id: args[:id].present? ? args[:id] : 'email',
        }

        super(name, **args, &block)

        hide_on :edit

        @squared = args[:squared].present? ? args[:squared] : false
        @size = args[:size].present? ? args[:size].to_i : 0
        @default_url = args[:default_url].present? ? ERB::Util.url_encode(args[:default_url]).to_s : ''
      end

      def hydrate_resource(model, resource, view)
        {
          squared: @squared,
          default_url: @default_url,
          size: @size,
        }
      end

      def fetch_for_resource(model, resource, view)
        fields = super(model, resource, view)
        fields[:value] = Digest::MD5.hexdigest model[id].strip.downcase
        fields
      end
    end
  end
end
