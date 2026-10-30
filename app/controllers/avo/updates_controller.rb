module Avo
  class UpdatesController < Avo::ApplicationController
    before_action :authenticate_developer_or_admin!
    # Running bundler and restarting the server from a web request is only safe on a developer's machine.
    before_action :require_updater, only: [:run, :restart]
    helper_method :installed?

    def index
      @installed = Avo::Services::GemVersions.installed
      @releases = Avo::Services::GemVersions.releases_since(Avo::Services::Updater.versions_before || @installed)
    end

    def progress
      render partial: "avo/updates/progress"
    end

    def run
      Avo::Services::Updater.start

      render partial: "avo/updates/progress"
    end

    def restart
      Avo::Services::Updater.restart

      render partial: "avo/updates/progress", locals: {restarting: true}
    end

    private

    def installed?(release)
      Gem::Version.new(release["version"]) <= Gem::Version.new(@installed[release["gem"]].to_s)
    rescue ArgumentError
      false
    end

    def require_updater
      head :forbidden unless Avo::Services::Updater.allowed?
    end
  end
end
