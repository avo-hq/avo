module Avo
  module InitializesAvo
    def init_app
      Avo::Current.license = Avo::Licensing::NilLicense.new
      Avo::Current.context = context
      Avo::Current.user = _current_user
      Avo::Current.view_context = view_context
      Avo.init
      # TODO: Simplify this
      Avo::Current.license = Licensing::LicenseManager.license

      # Output a warning in the logs if the license is invalid
      if Avo::Current.license.invalid?
        Avo.logger.debug "Your Avo license looks invalid. Please troubleshoot it using the directions here: https://docs.avohq.io/3.0/license-troubleshooting.html"
      end

      Avo::Current.locale = locale
    end

    def _current_user
      instance_eval(&Avo.configuration.current_user)
    end

    def context
      instance_eval(&Avo.configuration.context)
    end
  end
end
