module Avo
  module ApplicationHelper
    include ::Webpacker::Helper

    def current_webpacker_instance
      Avo.webpacker
    end

    def render_logo
      render partial: 'vendor/avo/partials/logo' rescue render partial: 'partials/logo'
    end

    def render_header
      render partial: 'vendor/avo/partials/header' rescue render partial: 'partials/header'
    end

    def render_footer
      render partial: 'vendor/avo/partials/footer' rescue render partial: 'partials/footer'
    end

    def render_scripts
      render partial: 'vendor/avo/partials/scripts' rescue ''
    end
  end
end
