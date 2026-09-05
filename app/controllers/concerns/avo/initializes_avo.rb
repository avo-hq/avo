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
      prepend_theme_view_path

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

    # A theme with a views directory overrides Avo's partials while it is
    # active. Prepending per request (not at boot) is what makes the override
    # per user: two admins on two themes see two logos from one process. The
    # theme directory goes ahead of app/views on purpose — the theme is the
    # more specific intent, and an app customizes a themed partial by ejecting
    # it into the theme (`rails g avo:eject --partial :logo --theme <id>`).
    def prepend_theme_view_path
      theme = helpers.current_theme
      return unless theme&.has_views?

      prepend_view_path theme.views.to_s
    end

    def load_appearance_settings
      appearance = Avo.configuration.appearance

      return unless appearance.database_persistence? && appearance.load_settings_block.present?

      Avo::Current.appearance_settings = Avo::ExecutionContext.new(
        target: appearance.load_settings_block,
        current_user: _current_user
      ).handle
    end
  end
end
