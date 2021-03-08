# Overriding the 1.7.1 version of WebpackAssetFinder to add custom webpacker instance
module InlineSvg
  class WebpackAssetFinder
    def initialize(filename)
      @filename = filename
      @webpacker = Avo.webpacker
      @asset_path = @webpacker.manifest.lookup(@filename)
    end

    def pathname
      return if @asset_path.blank?

      if @webpacker.dev_server.running?
        dev_server_asset(@asset_path)
      elsif @webpacker.config.public_path.present?
        File.join(@webpacker.config.public_path, @asset_path)
      end
    end

    private

    def fetch_from_dev_server(file_path)
      http = Net::HTTP.new(@webpacker.dev_server.host, @webpacker.dev_server.port)
      http.use_ssl = @webpacker.dev_server.https?
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      http.request(Net::HTTP::Get.new(file_path)).body
    rescue StandardError => e
      Rails.logger.error "[inline_svg] Error fetching #{@filename} from webpack-dev-server: #{e}"
      raise
    end
  end
end
