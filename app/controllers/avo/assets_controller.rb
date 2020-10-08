require_dependency 'avo/application_controller'

module Avo
  class AssetsController < ApplicationController
    protect_from_forgery except: :script

    def script
      # @todo: add check if changed middleware
      file = "#{params[:script]}.#{params[:format]}"
      tool_path = Pathname.new(App.get_script_path(file).gsub('/frontend', ''))
      config_path = tool_path.join('config', 'webpacker.yml')
      webpacker = ::Webpacker::Instance.new(root_path: tool_path, config_path: config_path)
      webpacker.manifest.refresh

      begin
        if webpacker.dev_server.running?
          file_path = "#{webpacker.dev_server.protocol}://#{webpacker.dev_server.host_with_port}#{webpacker.manifest.lookup!(file).to_s}"

          request = HTTParty.get file_path
          @contents = request.body
        else
          compiled_file = webpacker.manifest.lookup!(file).to_s
          compiled_file = compiled_file[1..-1]
          compiled_file_path = tool_path.join('public', compiled_file)

          @contents = File.read(compiled_file_path.to_s)
        end

      rescue => exception
        return render plain: '404', status: 404
      end

      respond_to do |format|
        format.js {
          render 'scripts'
        }
      end
    end
  end
end
