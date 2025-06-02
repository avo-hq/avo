class Avo::Forms::Settings::General < Avo::Core::Forms::Base
  def fields
    panel "App Settings", description: "Manage your app settings" do
      field :name, format_using: -> { Avo.configuration.app_name }
      field :url, format_using: -> { "https://avohq.io" }
    end

    panel "Profile Settings", description: "Manage your profile settings" do
      cluster do
        with_options stacked: true, record: Avo::Current.user do
          field :first_name
          field :last_name
        end
      end

      field :email, record: Avo::Current.user
    end
  end

  def handle
    cookies[:app_name] = params[:name]

    current_user.update(params.permit(:first_name, :last_name, :email))

    flash[:notice] = "Cool"
  end
end
