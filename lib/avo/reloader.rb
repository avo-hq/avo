class Avo::Reloader
  delegate :execute_if_updated, :execute, :updated?, to: :updater

  def reload!
    # reload all files declared in paths
    paths.each { |path| load path }

    # reload all files declared in each directory
    directories.keys.each do |dir|
      Dir.glob("#{dir}/**/*.rb".to_s).each { |c| load c }
    end
  end

  private
    def updater
      @updater ||= config.file_watcher.new(paths, directories) { reload! }
    end

    def paths
      # we want to watch some files no matter what
      files = [
        Rails.root.join("config", "initializers", "avo.rb"),
      ]

      # we want to watch some files only in Avo development
      if reload_lib?
        files += []
      end

      files
    end

    def directories
      dirs = {}

      # watch the lib directory in Avo development
      if reload_lib?
        dirs[Avo::Engine.root.join("lib", "avo").to_s] = ["rb"]
      end

      dirs
    end

    def config
      Rails.application.config
    end

    def reload_lib?
      Avo::IN_DEVELOPMENT || ENV['AVO_RELOAD_LIB_DIR']
    end
end
