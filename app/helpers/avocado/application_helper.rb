module Avocado
  module ApplicationHelper
    include ::Webpacker::Helper

    def current_webpacker_instance
      Avocado.webpacker
    end

    def render_navigation
      resources = Avocado::App.get_resources

      render partial: 'avocado/partials/navigation', locals: {resources: resources}
    end

    def sidebar_heading(name)
      "<div class='font-bold text-2xl'>#{name}</div>".html_safe
    end

    def router_link(name, url)
      "<router-link to='#{url}' class='text-white font-semibold'>#{name}</router-link>".html_safe
    end

    def resource_item(name, url)
      url = "/resources/#{url}"
      router_link name, url
    end
  end
end
