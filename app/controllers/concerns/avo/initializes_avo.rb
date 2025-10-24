module Avo
  module InitializesAvo
    def init_app
      Avo::Current.context = context
      Avo::Current.user = _current_user
      Avo::Current.view_context = view_context
      Avo.init
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
