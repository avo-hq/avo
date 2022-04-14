class Avo::Menu::Resource < Avo::Menu::BaseItem
  extend Dry::Initializer

  option :resource

  def parsed_resource
    Avo::App.guess_resource resource.to_s
  end
end
