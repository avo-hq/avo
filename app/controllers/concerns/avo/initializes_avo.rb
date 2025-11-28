module Avo
  module InitializesAvo
    def init_app
      Avo::Current.context = context
      Avo::Current.user = _current_user
      Avo::Current.view_context = view_context
      Avo.init
      Avo::Current.locale = locale

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
  end
end
