module Avo
  module Concerns
    module HasFields
      extend ActiveSupport::Concern

      included do
        class_attribute :items_holder
        class_attribute :items_index, default: 0
        class_attribute :tabs_holder
        class_attribute :tabs_tabs_holder
        class_attribute :raw_tabs
        class_attribute :tools_holder
      end
      delegate :items, to: :items_holder

      class_methods do
        delegate :add_tool, to: ::Avo::Services::DslService
        delegate :tool, to: :items_holder
        delegate :items, to: :items_holder


        def tools
          self.tools_holder
        end

        def field(name, **args, &block)
          init_items

          self.items_holder.field name, **args, &block
        end

        def panel(name = nil, **args, &block)
          init_items

          self.items_holder.panel name, **args, &block
        end

        def tabs(&block)
          init_items

          self.items_holder.tabs Avo::TabGroupBuilder.parse_block(&block)
        end

        def heading(body, **args)
          self.items_holder.add_item Avo::Fields::HeadingField.new(body, order_index: items_index, **args)
        end

        def fields
          self.items.select do |item|
            next if item.nil?

            item.is_field?
          end
        end

        def tab_groups
          self.items.select do |item|
            item.instance_of? Avo::TabGroup
          end
        end

        private

        def init_items
          self.items_holder ||= Avo::ItemsHolder.new
        end

        def add_to_fields(instance)
          self.items ||= []
          self.items << instance
          increment_order_index
        end

        def increment_order_index
          self.items_index += 1
        end
      end

      def get_tabs
        tabs_holder
      end

      def fields
        self.class.fields
      end

      def tab_groups
        self.class.tab_groups
      end

      def get_field_definitions
        fields = self.class.fields

        return [] if fields.blank?

        items = fields.map do |field|
          field.hydrate(resource: self, panel_name: default_panel_name, user: user)
        end

        if Avo::App.license.lacks_with_trial(:custom_fields)
          items = items.reject do |field|
            field.custom?
          end
        end

        if Avo::App.license.lacks_with_trial(:advanced_fields)
          items = items.reject do |field|
            field.type == "tags"
          end
        end

        items
      end

      def get_fields(panel: nil, reflection: nil)
        fields = get_field_definitions
          .select do |field|
            field.send("show_on_#{@view}")
          end
          .select do |field|
            field.visible?
          end
          .select do |field|
            is_valid = true

            # Strip out the reflection field in index queries with a parent association.
            if reflection.present?
              # regular non-polymorphic association
              # we're matching the reflection inverse_of foriegn key with the field's foreign_key
              if field.is_a?(Avo::Fields::BelongsToField)
                if field.respond_to?(:foreign_key) &&
                    reflection.inverse_of.present? &&
                    reflection.inverse_of.foreign_key == field.foreign_key
                  is_valid = false
                end

                # polymorphic association
                if field.respond_to?(:foreign_key) &&
                    field.is_polymorphic? &&
                    reflection.respond_to?(:polymorphic?) &&
                    reflection.inverse_of.foreign_key == field.reflection.foreign_key
                  is_valid = false
                end
              end
            end

            is_valid
          end

        if panel.present?
          fields = fields.select do |field|
            field.panel_name == panel
          end
        end

        hydrate_fields(model: @model, view: @view)

        fields
      end

      def get_field(id)
        get_field_definitions.find do |f|
          f.id == id.to_sym
        end
      end

      def tools
        # abort self.class.tools.inspect
        # abort self.inspect
        check_license

        return [] if App.license.lacks_with_trial :resource_tools
        return [] if self.class.tools.blank?
        # abort self.class.tools_holder.inspect

        # .map do |tool|
        #   tool.hydrate view: view
        #   tool
        # end
        # .select do |field|
        #   # field.send("show_on_#{view}")
        #   true
        # end
        # [3,4,5]
        self.items.select do |item|
          next if item.nil?

          item.is_tool?
        end
      end

      def get_items
        # return items

        panelless_items = []
        panelfull_items = []

        items.each do |item|
          if item.is_field?
            if item.has_own_panel?
              panelfull_items << item
            else
              panelless_items << item
            end
          else
            panelfull_items << item
          end
        end

        # panelfull_items = items.select do |item|
        #   if item.is_field? && item.has_own_panel?
        #     false
        #   else
        #     true
        #   end
        # end

        puts ["panelfull_fields->", items.count, panelfull_items.count, panelless_items.count, items.map(&:item_type)].inspect

        i_holder = Avo::ItemsHolder.new
        i_holder.items = panelless_items

        main_panel = Avo::MainPanel.new(name: default_panel_name, description: resource_description)
        main_panel.items_holder = i_holder

        [main_panel, *panelfull_items]
      end

      def get_base_items
        panelless_fields = items.select do |field|
          field.is_field? && !field.has_own_panel?
        end

        panelless_fields

        # panelfull_fields = items.select do |field|
        #   field.is_field? && field.has_own_panel?
        # end

        # puts ["panelfull_fields->", panelfull_fields.count, panelless_fields.count].inspect

        # [Avo::Panel.new(name: default_panel_name, description: resource_description, items: panelless_fields, is_main_panel: true), *panelfull_fields]
      end

      private

      def check_license
        if !Rails.env.production? && App.license.present? && App.license.lacks(:resource_tools)
          # Add error message to let the developer know the resource tool will not be available in a production environment.
          Avo::App.error_messages.push "Warning: Your license is invalid or doesn't support resource tools. The resource tools will not be visible in a production environment."
        end
      end
    end
  end
end

module Avo
  class ItemsHolder
    attr_reader :tools
    # attr_reader :filters
    # attr_reader :actions
    attr_accessor :items

    def initialize
      @items = []
      @items_index = 0
      @invalid_fields = []

      puts ["ItemsHolder initialize->"].inspect
    end

    def field(field_name, **args, &block)
      # puts ["ItemsHolder field->", field_name, resource_class, args, block].inspect

      field_parser = Avo::Dsl::FieldParser.new(id: field_name, order_index: @items_index, **args, &block).parse
      puts ["field_parser->", field_parser].inspect

      if field_parser.invalid?
        as = args.fetch(:as, nil)
        add_invalid_field({
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

    def tool(klass, **args)
      # puts ["ItemsHolder tool->", klass, args].inspect
      instance = klass.new **args
      add_item instance
    end

    def panel(panel_name = nil, **args, &block)
      panel = Avo::PanelBuilder.parse_block(name: panel_name, **args, &block)

      add_item panel
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


# class Avo::UniversalBuilder
#   class << self
#     def parse_block(&block)
#       Docile.dsl_eval(new, &block).build
#     end
#   end
# end

# @Final
class Avo::TabGroupBuilder
  class << self
    def parse_block(&block)
      Docile.dsl_eval(new, &block).build
    end
  end

  attr_reader :items_holder

  delegate :tab, to: :items_holder

  def initialize
    @group = Avo::TabGroup.new
    @items_holder = Avo::ItemsHolder.new
  end

  def field(field_name, **args, &block)
    parsed = Avo::Dsl::FieldParser.new(id: field_name, order_index: @items_index, **args, &block).parse
    field_instance = parsed.instance

    name = field_instance.name
    tab = Avo::Tab.new name: name

    if field_instance.has_own_panel?
      tab.items_holder.add_item parsed.instance
    else
      panel = Avo::Panel.new name: name
      panel.items_holder.add_item parsed.instance
      tab.items_holder.add_item panel
    end

    # abort [1, tab, 2, tab.items_holder, 3, field].inspect

    # abort [t, parsed.instance].inspect

    @items_holder.tabs tab

    # @items_holder << tab
  end

  # Fetch the tab
  def build
    @group.items_holder = @items_holder
    @group
  end
end

class Avo::TabBuilder
  class << self
    def parse_block(**args, &block)
      Docile.dsl_eval(new(**args), &block).build
    end
  end

  attr_reader :items_holder

  delegate :field, to: :items_holder
  delegate :tool, to: :items_holder
  delegate :panel, to: :items_holder
  delegate :items, to: :items_holder

  def initialize(name: nil, **args)
    @tab = Avo::Tab.new(name: name, **args)
    @items_holder = Avo::ItemsHolder.new
  end

  # Fetch the tab
  def build
    @tab.items_holder = @items_holder
    @tab
  end
end

class Avo::PanelBuilder
  class << self
    def parse_block(**args, &block)
      Docile.dsl_eval(new(**args), &block).build
    end
  end

  delegate :field, to: :items_holder
  delegate :items, to: :items_holder
  # delegate :tool, to: :items_holder
  # delegate :panel, to: :items_holder

  attr_reader :items_holder

  def initialize(name: nil, **args)
    @panel = Avo::Panel.new(name: name, **args)
    @items_holder = Avo::ItemsHolder.new
  end

  # Fetch the tab
  def build
    @panel.items_holder = @items_holder
    @panel
  end
end

class Avo::Tab
  include Avo::Concerns::HasFields
  include Avo::Concerns::IsResourceItem

  # @todo: fix the view
  class_attribute :view, default: :show
  class_attribute :item_type, default: :tab

  delegate :view, to: :self
  delegate :items, :add_item, to: :items_holder

  attr_reader :name
  attr_accessor :items_holder
  attr_accessor :description

  def initialize(name: nil, description: nil)
    @name = name
    @description = description
    @items_holder = Avo::ItemsHolder.new
  end

  # def items
  #   # spot fields that don't belong to a panel and add them to a panel
  #   # abort items.inspect
  #   new_items = []
  #   in_panel = false
  #   latest_panel = Avo::Panel.new
  #   last_item = nil

  #   items

  #   # items.each_with_index do |item, index|
  #   #   puts ["->", item.class.item_type, item.try(:name) || item.try(:id) || item.try(:name)].inspect
  #   #   if item.is_field?
  #   #     if in_panel || item.has_own_panel?
  #   #       puts ['->', 1].inspect
  #   #       new_items << item
  #   #     else
  #   #       puts ['->', 2].inspect
  #   #       # Add to latest panel
  #   #       latest_panel.add_item item
  #   #       # new_items << item
  #   #     end
  #   #   else
  #   #     puts ['->', 2.5].inspect

  #   #     if last_item.present? && last_item.is_field? && latest_panel.has_items?
  #   #       puts ['->', 3].inspect
  #   #       # Close the panel and add it to the new stack
  #   #       new_items << latest_panel
  #   #       in_panel = false
  #   #       latest_panel = Avo::Panel.new
  #   #     end
  #   #     # elsif item.is_panel?
  #   #     #   new_items << item
  #   #     # elsif item.is_tool?
  #   #     puts ['->', 4].inspect
  #   #     new_items << item
  #   #   end

  #   #   # If this is the last item
  #   #   if (index + 1) == items.count && latest_panel.items.count
  #   #     new_items << latest_panel
  #   #     in_panel = false
  #   #     latest_panel = Avo::Panel.new
  #   #     # puts ['->', 5, latest_panel.items.count].inspect
  #   #   end
  #   #   last_item = item
  #   # end

  #   # # # abort [new_items].inspect

  #   # @items = new_items

  # end
end

class Avo::TabGroup
  include Avo::Concerns::HasFields
  include Avo::Concerns::IsResourceItem

  class_attribute :view, default: :show
  class_attribute :item_type, default: :tab_group

  delegate :view, to: :self

  attr_accessor :index
  attr_accessor :items_holder

  def initialize(index: 0)
    @index = index
    @items_holder = Avo::ItemsHolder.new
  end

  def turbo_frame_id
    "#{Avo::TabGroup.to_s.parameterize} #{index}".parameterize
  end
end


class Avo::Panel
  include Avo::Concerns::IsResourceItem

  attr_reader :name
  attr_reader :description
  attr_accessor :items_holder

  class_attribute :item_type, default: :panel

  delegate :items, :add_item, to: :items_holder

  def initialize(name: nil, description: nil)
    @name = name
    @description = description
    @items_holder = Avo::ItemsHolder.new
  end

  def add_item(item)
    @items << item
  end

  def has_items?
    @items.present?
  end
end

class Avo::MainPanel < Avo::Panel
  class_attribute :item_type, default: :main_panel
end
