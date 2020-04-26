module Avocado
  module ApplicationHelper
    include ::Webpacker::Helper

    def current_webpacker_instance
      Avocado.webpacker
    end
  end
end
