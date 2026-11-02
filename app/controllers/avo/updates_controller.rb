module Avo
  class UpdatesController < Avo::ApplicationController
    before_action :authenticate_developer_or_admin!
    # Running bundler and restarting the server from a web request is only safe on a developer's machine.
    before_action :require_updater, only: [:run, :restart]
    helper_method :release_date

    def index
      @installed = Avo::Services::GemVersions.installed
      @page = [params[:page].to_i, 1].max
      changelog = Avo::Services::GemVersions.releases(page: @page)
      @releases = changelog["releases"]
      @installed_releases, @available_releases = @releases.partition { |release| installed?(release) }
      @next_page = changelog["next_page"]
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

    # In UTC, so a release reads the same day in every app.
    def release_date(release)
      Time.iso8601(release["released_at"].to_s).utc.to_date
    rescue ArgumentError
      nil
    end

    def require_updater
      head :forbidden unless Avo::Services::Updater.allowed?
    end
  end
end
