class Avo::Actions::City::Update < Avo::BaseAction
  self.name = "Update"
  self.visible = -> { false }

  def fields
    field :name, as: :text if arguments[:render_name]
    field :population, as: :number if arguments[:render_population]
  end

  def handle(**args)
    City.find(arguments[:cities]).each do |city|
      city.update! args[:fields]
    end

    succeed "City updated!"
  end
end
