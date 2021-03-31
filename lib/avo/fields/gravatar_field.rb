require "digest"
require "erb"

module Avo
  module Fields
    class GravatarField < BaseField
      attr_reader :size
      attr_reader :rounded
      attr_reader :default

      def initialize(name, **args, &block)
        @defaults = {
          partial_name: "gravatar-field",
          name: "Avatar",
          id: args[:id].present? ? args[:id] : "email"
        }

        super(name, **args, &block)

        hide_on [:edit, :new]

        @rounded = args[:rounded].present? ? args[:rounded] : true
        @size = args[:size].present? ? args[:size].to_i : 40
        @default = args[:default].present? ? ERB::Util.url_encode(args[:default]).to_s : ""
        @link_to_resource = args[:link_to_resource].present? ? args[:link_to_resource] : false
      end

      def md5
        return if value.blank?

        Digest::MD5.hexdigest(value.strip.downcase)
      end

      def to_image
        options = {
          default: "",
          size: 340
        }

        query = options.map { |key, value| "#{key}=#{value}" }.join("&")

        URI::HTTPS.build(host: "www.gravatar.com", path: "/avatar/#{md5}", query: query).to_s
      end
    end
  end
end
