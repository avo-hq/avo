# Downloaded from https://collectiveidea.com/blog/archives/2012/01/27/testing-file-downloads-with-capybara-and-chromedriver

module DownloadHelpers
  TIMEOUT = 10
  PATH = Rails.root.join("tmp", "downloads")

  extend self

  def downloads
    # puts ["PATH->", PATH, Dir[PATH.join("*")], Dir[Rails.root.to_s]].inspect
    Dir[PATH.join("*")]
  end

  def download
    downloads.first
  end

  def download_content
    wait_for_download
    File.read(download)
  end

  def wait_for_download
    sleep 0.1 # Add extra sleep to make sure we capture that download

    puts ["Dir.entries(DownloadHelpers::PATH)->", Dir.entries(DownloadHelpers::PATH)].inspect
    Timeout.timeout(TIMEOUT) do
      puts ["Dir.entries(DownloadHelpers::PATH)->", Dir.entries(DownloadHelpers::PATH)].inspect
      sleep 0.1 until downloaded?
    end
  end

  def downloaded?
    !downloading? && downloads.any?
  end

  def downloading?
    downloads.grep(/\.crdownload$/).any?
  end

  def clear_downloads
    FileUtils.rm_f(downloads)
  end

  def ensure_directory_exists
    puts ["ensure_directory_exists->"].inspect
    # dirname = DownloadHelpers::PATH
    unless File.directory?(PATH)
      FileUtils.mkdir_p(PATH)
    end
    puts ["File.directory?(PATH)->", PATH, DownloadHelpers::PATH, File.directory?(PATH)].inspect
  end
end
