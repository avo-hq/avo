require "dry-initializer"

class Avo::Menu::BaseItem
  extend Dry::Initializer

  option :collapsable, default: proc { false }
  option :collapsed, default: proc { false }
  option :icon, optional: true
  option :items, default: proc { [] }
  option :name, default: proc { "" }
  option :visible, default: proc { true }

  def visible?
    return visible if visible.in? [true, false]

    if visible.respond_to? :call
      Avo::Hosts::BaseHost.new(block: visible).handle
    end
  end
end
