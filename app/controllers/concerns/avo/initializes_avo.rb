module Avo
  module InitializesAvo
    def init_app
      Avo::Current.license = Avo::Licensing::NilLicense.new
      Avo::Current.context = context
      Avo::Current.user = _current_user
      Avo::Current.view_context = view_context
      Avo.init
      Avo::Current.license = Licensing::LicenseManager.new(Licensing::HQ.new(request).response).license
      Avo::Current.locale = locale
      Avo.plugin_manager.init_plugins
    end

    def _current_user
      instance_eval(&Avo.configuration.current_user)
    end

    def context
      instance_eval(&Avo.configuration.context)
    end
  end
end
