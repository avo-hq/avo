class Avo::Menu::Link < Avo::Menu::BaseItem
  option :path, default: proc { "" }
  option :target, optional: true
  option :method, optional: true
  option :params, optional: true
end
