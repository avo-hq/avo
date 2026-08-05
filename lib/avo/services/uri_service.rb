# frozen_string_literal: true

module Avo
  module Services
    class URIService
      class << self
        def parse(path)
          new path
        end
      end

      attr_reader :uri

      def initialize(path = "")
        @uri = Addressable::URI.parse(path)
      end

      def call
        to_s
      end

      def append_paths(*paths)
        paths = Array.wrap(paths).flatten

        return self if paths.blank?

        # Add the intermediary forward slash
        @uri.path.concat("/") unless @uri.path.ends_with? "/"

        # Add the paths to the URI
        @uri.path = @uri.path.concat(join_paths(paths))

        self
      end
      alias_method :append_path, :append_paths

      def append_query(params)
        params = if params.is_a? Hash
          params.map do |key, value|
            "#{key}=#{value}"
          end
        else
          {}
        end

        return self if params.blank?

        # Add the query params to the URI
        @uri.query = [@uri.query, *params].compact.join("&")

        self
      end

      def to_s
        @uri.to_s
      end

      private

      def join_paths(paths)
        paths
          .map do |path|
            sanitize_path path
          end
          .join("/")
      end

      # Removes the forward slash if it's present at the start of the path
      def sanitize_path(path)
        path = path[1..] if path.to_s.starts_with? "/"

        ERB::Util.url_encode path
      end
    end
  end
end
