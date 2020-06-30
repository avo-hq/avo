require_relative 'field'
require 'digest'
require 'erb'

module Avocado
  module Fields
    class GravatarField < Field
      def initialize(name, **args, &block)
        @defaults = {
          component: 'gravatar-field',
          # id: 'gravatar_' + args[:email].to_s.parameterize.underscore,
        }

        super(name, **args, &block)

        hide_on :edit

        @rounded = args[:rounded].present? ? args[:rounded] : true
        @squared = args[:squared].present? ? args[:squared] : false
        @size = args[:size].present? ? args[:size].to_i : 0
        @default_url = args[:default_url].present? ? ERB::Util.url_encode(args[:default_url]).to_s : ''

        # the email is prepared based on the following rules:
        # 1. Trim leading and trailing whitespace from an email address
        # 2. Force all characters to lower-case
        # 3. md5 hash the final string
        @email = args[:email].present? ? (Digest::MD5.hexdigest args[:email].strip.downcase).to_s : ''
      end

      def hydrate_resource(model, resource, view)
        {
          rounded: @rounded,
          squared: @squared,
          default_url: @default_url,
          size: @size,
          email: @email,
        }
      end

      # def fetch_for_resource(model, resource, view)
      #   fields = super(model, resource, view)
      #   fields[:value] = get_gravatar_image(fields[:value])
      #   fields
      # end

      # def get_gravatar_image(value)
      #   value = 'email'
      #   value
      # end
    end
  end
end
