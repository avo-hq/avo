module Avo
  # Stores the viewer's language in a cookie. Unlike `?set_locale=`, which
  # rewrites Avo.configuration.locale for the whole process, this only changes
  # what the browser that sent the request sees.
  class LocalesController < Avo::ApplicationController
    def update
      return head :not_found unless Avo.configuration.locale_selector_enabled?

      locale = params[:locale].to_s

      if Avo.configuration.locale_selector_locales.include?(locale)
        cookies[Avo::Locales::COOKIE_NAME] = {value: locale, path: "/", same_site: :lax, httponly: true, expires: 1.year}
      end

      redirect_back fallback_location: root_path, status: :see_other
    end
  end
end
