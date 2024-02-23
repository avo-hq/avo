class Avo::Actions::City::PreUpdate < Avo::BaseAction
  self.name = "Update"

  def fields
    field :name, as: :boolean
    field :population, as: :boolean
  end

  def handle(**args)
    arguments = Avo::Services::EncryptionService.encode_arguments(
      cities: args[:query].map(&:id),
      render_name: args[:fields][:name],
      render_population: args[:fields][:population]
    )

    navigate_to_action Avo::Actions::City::Update, arguments:
  end
end
