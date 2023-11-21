class Avo::Resources::Items::Holder
  attr_reader :tools, :from
  attr_accessor :items
  attr_accessor :invalid_fields

  def initialize(from: nil, parent: nil)
    @items = []
    @items_index = 0
    @invalid_fields = []
    @from = from
    @parent = parent
  end

  # Adds a field to the items_holder
  def field(field_name, **args, &block)
    # If the field is paresed inside a tab group, add it to the tab
    # This will happen when the field is parsed inside a tab group from a resource method
    if from.present? && from.class == Avo::Resources::Items::TabGroup::Builder
      return from.field(field_name, holder: self, **args, &block)
    end

    field_parser = Avo::Dsl::FieldParser.new(id: field_name, order_index: @items_index, **args, &block).parse

    if field_parser.invalid?
      as = args.fetch(:as, nil)

      # End execution ehre and add the field to the invalid_fileds payload so we know to wanr the developer about that.
      # @todo: Make sure this warning is still active
      return add_invalid_field({
        name: field_name,
        as: as,
        # resource: resource_class.name,
        message: "There's an invalid field configuration for this resource. <br/> <code class='px-1 py-px rounded bg-red-600'>field :#{field_name}, as: :#{as}</code>"
      })
    end

    add_item field_parser.instance
  end

  def tabs(tab = nil, **kwargs, &block)
    if tab.present?
      add_item tab
    else
      add_item Avo::Resources::Items::TabGroup::Builder.parse_block(parent: @parent, **kwargs, &block)
    end
  end

  def tab(name, **args, &block)
    add_item Avo::Resources::Items::Tab::Builder.parse_block(name: name, parent: @parent, **args, &block)
  end

  def row(**args, &block)
    add_item Avo::Resources::Items::Row::Builder.parse_block(parent: @parent, **args, &block)
  end

  def tool(klass, **args)
    add_item klass.new(**args)
  end

  def panel(panel_name = nil, **args, &block)
    add_item Avo::Resources::Items::ItemGroup::Builder.parse_block(name: panel_name, parent: @parent, **args, &block)
  end

  # The main panel is the one that also render the header of the resource with the breadcrumbs, the title and the controls.
  def main_panel(**args, &block)
    add_item Avo::Resources::Items::MainPanel::Builder.parse_block(name: "main_panel", parent: @parent, **args, &block)
  end

  def sidebar(**args, &block)
    check_sidebar_is_inside_a_panel

    add_item Avo::Resources::Items::Sidebar::Builder.parse_block(parent: @parent, **args, &block)
  end

  def add_item(instance)
    @items << instance

    increment_order_index
  end

  private

  def add_invalid_field(payload)
    invalid_fields << payload
  end

  def increment_order_index
    @items_index += 1
  end

  def check_sidebar_is_inside_a_panel
    unless @from.eql?(Avo::Resources::Items::Panel::Builder) || @from.eql?(Avo::Resources::Items::MainPanel::Builder)
      raise "The sidebar must be inside a panel."
    end
  end
end
