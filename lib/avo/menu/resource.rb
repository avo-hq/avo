class Avo::Menu::Resource < Avo::Menu::BaseItem
  extend Dry::Initializer

  option :resource
  option :label, optional: true

  def parsed_resource
    Avo::App.guess_resource resource.to_s
  end

  def entity_label
    parsed_resource.navigation_label
  end
end
