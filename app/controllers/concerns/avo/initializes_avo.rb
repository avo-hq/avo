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

    def default_url_options
      result = super.dup

      if params[:force_locale].present?
        result[:force_locale] = params[:force_locale]
      end

      extra_options = get_extra_default_url_options

      if extra_options.present?
        extra_options.each do |param_name|
          result[param_name] = params[param_name]
        end
      end

      result
    end

    def get_extra_default_url_options
      block_or_array = Avo.configuration.default_url_options

      if block_or_array.respond_to?(:call)
        instance_eval(&block_or_array)
      else
        block_or_array
      end
    end
  end
end
