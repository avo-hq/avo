class PreUpdate < Avo::BaseAction
  self.name = "Update"
  self.message = "Set the fields you want to update."

  with_options as: :boolean do
    field :first_name
    field :last_name
    field :user_email
    field :active
    field :admin
  end

  def handle(**args)
    arguments = Base64.encode64 Avo::Services::EncryptionService.encrypt(
      message: {
        render_first_name: args[:fields][:first_name],
        render_last_name: args[:fields][:last_name],
        render_user_email: args[:fields][:user_email],
        render_active: args[:fields][:active],
        render_admin: args[:fields][:admin]
      },
      purpose: :action_arguments
    )

    redirect_to "/admin/resources/users/actions?action_id=Update&arguments=#{arguments}", turbo_frame: "actions_show"
  end
end
