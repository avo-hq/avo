module Avocado
  module ApplicationHelper
    include ::Webpacker::Helper

    def current_webpacker_instance
      Avocado.webpacker
    end

    def say_bye
      'bye bye'
    end
  end
end
