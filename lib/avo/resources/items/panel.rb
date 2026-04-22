class Avo::Resources::Items::Panel < Avo::Resources::Items::ItemGroup
  def get_items
    items_with_standalone_fields_wrapped_in_cards
  end
end
