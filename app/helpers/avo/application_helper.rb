module Avo
  module ApplicationHelper
    include ::Webpacker::Helper

    def current_webpacker_instance
      Avo.webpacker
    end

    def render_logo
      render partial: 'vendor/avo/partials/logo' rescue render partial: 'partials/logo'
    end

    def render_footer
      render partial: 'vendor/avo/partials/footer' rescue render partial: 'partials/footer'
    end
  end
end
