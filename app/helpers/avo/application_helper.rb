module Avo
  module ApplicationHelper
    include ::Webpacker::Helper

    def current_webpacker_instance
      Avo.webpacker
    end

    def render_logo
      render partial: 'vendor/avo/partials/logo' rescue render partial: 'avo/partials/logo'
    end

    def render_header
      render partial: 'vendor/avo/partials/header' rescue render partial: 'avo/partials/header'
    end

    def render_footer
      render partial: 'vendor/avo/partials/footer' rescue render partial: 'avo/partials/footer'
    end

    def render_scripts
      render partial: 'vendor/avo/partials/scripts' rescue ''
    end

    def render_resource_navigation
      render partial: 'avo/sidebar/resources_navigation', locals: {resources: Avo::App.get_available_resources(_current_user)}
    end

    def sidebar_link(label, link, **options)
      active = options[:active].present? ? options[:active] : :inclusive

      render partial: 'avo/sidebar/sidebar_link', locals: {
        label: label,
        link: link,
        active: active,
        options: options
      }
    end

    def render_license_warnings
      render partial: 'avo/sidebar/license_warnings', locals: {
        license: Avo::App.license.properties,
      }
    end

    def render_license_warning(title: '', message: '', icon: 'exclamation')
      render partial: 'avo/sidebar/license_warning', locals: {
        title: title,
        message: message,
        icon: icon,
      }
    end

    def panel(&block)
      # abort @view_flow.inspect
      # abort content_for?(:heading).inspect
      # abort capture(&block).inspect
      render layout: 'layouts/avo/panel' do
        capture(&block)
      end
    end
  end
end
