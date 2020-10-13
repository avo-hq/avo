require_dependency 'avo/application_controller'

module Avo
  class AssetsController < ApplicationController
    protect_from_forgery except: [:script, :map]

    def script
      # @todo: add check if_asset_changed middleware
      @file = @script_name = "#{params[:script]}.#{params[:format]}"

      set_contents

      render plain: @contents, content_type: 'text/javascript' if @contents.present?
    end

    def map
      file = "#{params[:script]}.#{params[:format]}"
      registered_script_name = file.match(/(.+?)-\S*\.js\.map/i).captures.first
      @script_name = "#{registered_script_name}.js"
      @file = "#{registered_script_name}.#{params[:format]}"

      set_contents

      render plain: @contents if @contents.present?
    end

    private
      def set_contents
        begin
          tool_path = Pathname.new(App.get_script_path(@script_name).gsub('/frontend', ''))
          config_path = tool_path.join('config', 'webpacker.yml')
          webpacker = ::Webpacker::Instance.new(root_path: tool_path, config_path: config_path)
          webpacker.manifest.refresh
          if webpacker.dev_server.running?
            file_path = "#{webpacker.dev_server.protocol}://#{webpacker.dev_server.host_with_port}#{webpacker.manifest.lookup!(@file).to_s}"

            request = HTTParty.get file_path
            @contents = request.body
          else
            compiled_file = webpacker.manifest.lookup!(@file).to_s
            compiled_file = compiled_file[1..-1]
            compiled_file_path = tool_path.join('public', compiled_file)

            @contents = File.read(compiled_file_path.to_s)
          end

        rescue => exception
          return render plain: '404', status: 404
        end
      end
  end
end
