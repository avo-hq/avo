module Avo
  module ApplicationHelper
    include ::Webpacker::Helper

    def current_webpacker_instance
      Avo.webpacker
    end

    def render_logo_partial
      render partial: 'vendor/avo/partials/logo' rescue image_pack_tag 'logo.png', class: 'h-full', title: 'Avo'
    end
  end
end
