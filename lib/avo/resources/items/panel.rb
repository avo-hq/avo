class Avo::Resources::Items::Panel < Avo::Resources::Items::ItemGroup
  include Avo::Concerns::HasTranslatableTitle

  def get_items
    items_with_standalone_fields_wrapped_in_cards
  end

  private

  def title_translation_scope
    "panels"
  end
end
