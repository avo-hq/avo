module Avo
  module Licensing
    class Request
      class << self
        def post(endpoint, body:, timeout:)
          uri = URI.parse(endpoint)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == "https")
          http.read_timeout = timeout
          http.open_timeout = timeout
          request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' => 'application/json'})
          request.body = body
          http.request(request)
        end
      end
    end
  end
end
