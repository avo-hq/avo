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
      load_appearance_settings

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

    def load_appearance_settings
      return unless Avo.configuration.appearance.database_persistence? && Avo.configuration.appearance.load_settings_block.present?

      Avo::Current.appearance_settings = Avo::ExecutionContext.new(
        target: Avo.configuration.appearance.load_settings_block,
        current_user: _current_user
      ).handle
    end
  end
end
