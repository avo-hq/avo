module Avo
  class ItemsHolder
    attr_reader :tools
    attr_writer :items
    attr_accessor :invalid_fields

    def items
      items = @items

      if Avo::App.license.lacks_with_trial(:custom_fields)
        items.reject! { |item| item.is_field? && item.custom? }
      end

      if Avo::App.license.lacks_with_trial(:advanced_fields)
        items.reject! { |item| item.is_field? && item.type == "tags" }
      end

      items
    end

    def initialize
      @items = []
      @items_index = 0
      @invalid_fields = []
    end

    # Adds a field to the bag
    def field(field_name, **args, &block)
      field_parser = Avo::Dsl::FieldParser.new(id: field_name, order_index: @items_index, **args, &block).parse

      if field_parser.invalid?
        as = args.fetch(:as, nil)

        # End execution ehre and add the field to the invalid_fileds payload so we know to wanr the developer about that.
        # @todo: Make sure this warning is still active
        return add_invalid_field({
          name: field_name,
          as: as,
          # resource: resource_class.name,
          message: "There's an invalid field configuration for this resource. <br/> <code class='px-1 py-px rounded bg-red-600'>field :#{field_name}, as: #{as}</code>"
        })
      end

      add_item field_parser.instance
    end

    def tabs(instance)
      add_item instance
    end

    def tab(name, **args, &block)
      add_item Avo::TabBuilder.parse_block(name: name, **args, &block)
    end

    def row(**args, &block)
      add_item Avo::RowBuilder.parse_block(**args, &block)
    end

    def tool(klass, **args)
      instance = klass.new(**args)
      add_item instance
    end

    def panel(panel_name = nil, **args, &block)
      panel = Avo::PanelBuilder.parse_block(name: panel_name, **args, &block)

      add_item panel
    end

    def heading(body = nil, **args, &block)
      field = Avo::Fields::HeadingField.new(body, **args)

      add_item field
    end

    def sidebar(instance)
      add_item instance
    end

    def add_item(instance)
      @items << instance

      increment_order_index
    end

    private

    def add_invalid_field(payload)
      @invalid_fields << payload
    end

    def increment_order_index
      @items_index += 1
    end
  end
end
