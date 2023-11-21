class Avo::Actions::City::PreUpdate < Avo::BaseAction
  self.name = "Update"

  def fields
    field :name, as: :boolean
    field :population, as: :boolean
  end

  def handle(**args)
    arguments = Base64.encode64 Avo::Services::EncryptionService.encrypt(
      message: {
        cities: args[:query].map(&:id),
        render_name: args[:fields][:name],
        render_population: args[:fields][:population]
      },
      purpose: :action_arguments
    )

    redirect_to "/admin/resources/city/actions?action_id=Avo::Actions::City::Update&arguments=#{arguments}", turbo_frame: "actions_show"
  end
end
