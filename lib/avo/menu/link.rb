class Avo::Menu::Link < Avo::Menu::BaseItem
  option :path, default: proc { "" }
  option :target, optional: true
end
