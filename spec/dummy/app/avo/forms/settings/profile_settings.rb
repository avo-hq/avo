class Avo::Forms::Settings::ProfileSettings < Avo::Core::Forms::Base
  self.title = "Profile Settings"
  self.description = "Manage your profile settings"

  def fields
    main_panel do
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
    current_user.update(params.permit(:first_name, :last_name, :email))

    flash[:notice] = "Profile updated successfully"
  end
end
