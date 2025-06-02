class Avo::Forms::Settings::AppSettings < Avo::Core::Forms::Base
  self.title = "App Settings"
  self.description = "Manage your app settings"

  def fields
    field :name, format_using: -> { Avo.configuration.app_name }
    field :url, format_using: -> { "https://avohq.io" }
  end

  def handle
    cookies[:app_name] = params[:name]
    flash[:notice] = "App settings updated successfully"
  end
end
