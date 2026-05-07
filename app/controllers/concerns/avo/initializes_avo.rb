module Avo
  module InitializesAvo
    include Avo::Concerns::SafeCall

    def init_app
      Avo::Current.context = context
      Avo::Current.user = _current_user
      Avo::Current.view_context = view_context
      safe_call(:before_init_app)
      Avo.init
      Avo::Current.locale = locale
      load_theme_settings

      # Fire and forget HQ reporting
      request_info = {ip: request.ip, host: request.host, port: request.port}
      Thread.new { Avo::Services::HqReporter.report(request_info) }
    end

    def _current_user
      instance_eval(&Avo.configuration.current_user)
    end

    def context
      instance_eval(&Avo.configuration.context)
    end

    def load_theme_settings
      appearance = Avo.configuration.appearance

      return unless appearance.database_persistence? && appearance.load_settings_block.present?

      Avo::Current.theme_settings = Avo::ExecutionContext.new(
        target: appearance.load_settings_block,
        current_user: _current_user
      ).handle
    end
  end
end
