require "dry-initializer"

class Avo::Menu::BaseItem
  extend Dry::Initializer

  option :name, default: proc { "" }
  option :items, default: proc { [] }
  option :collapsable, default: proc { false }
  option :visible, default: proc { true }
  option :icon, optional: true

  def visible?
    return visible if visible.in? [true, false]

    if visible.respond_to? :call
      Avo::Hosts::BaseHost.new(block: visible).handle
    end
  end
end
