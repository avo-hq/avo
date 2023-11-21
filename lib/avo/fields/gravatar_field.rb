require "digest"
require "erb"

module Avo
  module Fields
    class GravatarField < BaseField
      attr_reader :link_to_record
      attr_reader :rounded
      attr_reader :size
      attr_reader :default

      def initialize(id, **args, &block)
        args[:name] ||= "Avatar"

        super(id, **args, &block)

        hide_on [:edit, :new]

        @link_to_record = args[:link_to_record].present? ? args[:link_to_record] : false
        @rounded = args[:rounded].nil? ? true : args[:rounded]
        @size = args[:size].present? ? args[:size].to_i : 32
        @default = args[:default].present? ? ERB::Util.url_encode(args[:default]).to_s : ""
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
