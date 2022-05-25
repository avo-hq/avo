module Avo
  module Concerns
    module HasFields
      extend ActiveSupport::Concern

      included do
        class_attribute :items # can be: field, tool, panel, tab
        class_attribute :items_index, default: 0
        class_attribute :tabs_holder
        class_attribute :tabs_tabs_holder
        class_attribute :raw_tabs
        class_attribute :tools_holder
      end

      class_methods do
        # delegate :add_field, to: ::Avo::Services::DslService
        delegate :add_tool, to: ::Avo::Services::DslService

        def tool(klass, **args)
          puts ["tool->", klass].inspect
          self.tools_holder ||= []

          add_tool(items, klass, **args)
        end

        def tools
          self.tools_holder
          # [1,2,34]
          # ['asd']
        end

        def panel(panel_name = nil, **args, &block)
          panel = Avo::PanelBuilder.parse_block(name: panel_name, **args, &block)
          # field_parser = Avo::Dsl::FieldParser.new(id: panel_name, order_index: @tab.items_index, **args, &block).parse

          items << panel
          self.items_index += 1
        end

        def field(field_name, as:, **args, &block)
          self.invalid_fields ||= []

          field_parser = Avo::Dsl::FieldParser.new(id: field_name, as: as, order_index: items_index, **args, &block).parse

          if field_parser.invalid?
            self.invalid_fields << ({
              name: field_name,
              as: as,
              resource: name,
              message: "There's an invalid field configuration for this resource. <br/> <code class='px-1 py-px rounded bg-red-600'>field :#{field_name}, as: #{as}</code>"
            })
          end

          add_to_fields field_parser.instance
        end

        def heading(body, **args)
          add_to_fields Avo::Fields::HeadingField.new(body, order_index: items_index, **args)
        end

        def tabs(&block)
          tabs = Avo::TabGroupBuilder.parse_block(&block)
          self.items ||= []
          self.items << Avo::TabGroup.new(index: items_index, tabs: tabs)
          increment_order_index
        end

        def fields
          self.items.select do |item|
            next if item.nil?

            item.is_field?
          end
        end

        # def tools
        #   self.items.select do |item|
        #     # item.is_field?
        #     true
        #   end
        # end

        def tab_groups
          self.items.select do |item|
            item.instance_of? Avo::TabGroup
          end
        end

        private

        def add_to_fields(instance)
          self.items ||= []
          # add_field(fields, instance)
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
          field.hydrate(resource: self, panel_name: default_panel_name, user: user, translation_enabled: translation_enabled)
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

        [Avo::Panel.new(title: default_panel_name, description: resource_description, items: panelless_items, is_base_panel: true), *panelfull_items]
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

        # [Avo::Panel.new(title: default_panel_name, description: resource_description, items: panelless_fields, is_base_panel: true), *panelfull_fields]
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

class Avo::TabGroupBuilder
  class << self
    def parse_block(&block)
      Docile.dsl_eval(new, &block).build
    end
  end

  def initialize
    @items = []
  end

  def tab(name, **args, &block)
    # @items << name
    item = Avo::TabBuilder.parse_block(name: name, **args, &block)
    @items << item
  end

  # Fetch the tab
  def build
    @items
  end
end

class Avo::TabBuilder
  class << self
    def parse_block(**args, &block)
      Docile.dsl_eval(new(**args), &block).build
    end
  end

  delegate :add_tool, to: ::Avo::Services::DslService
  # delegate :add_field, to: ::Avo::Services::DslService

  def initialize(name: nil, **args)
    @tab = Avo::Tab.new(name: name, **args)

    @name = name
    @args = args
    @items = []
  end

  def tool(klass, **args)
    add_tool(@tab.items, klass, **args)
    # @tab.items << klass.new
    @tab.items_index += 1
    # puts ['!!!!->', klass].inspect
  end

  # def panel(klass, **args)
  #   # add_tool(@tab.items, klass, **args)
  #   @tab.items << klass.new
  #   @tab.items_index += 1
  #   # puts ['!!!!->', klass].inspect
  # end

  def field(field_name, **args, &block)
    field_parser = Avo::Dsl::FieldParser.new(id: field_name, order_index: @tab.items_index, **args, &block).parse

    if field_parser.valid?
      @tab.items << field_parser.instance
      @tab.items_index += 1
    end
  end

  def panel(panel_name = nil, **args, &block)
    panel = Avo::PanelBuilder.parse_block(name: panel_name, **args, &block)
    # field_parser = Avo::Dsl::FieldParser.new(id: panel_name, order_index: @tab.items_index, **args, &block).parse

    @tab.items << panel
    @tab.items_index += 1
  end

  # def tab(name, **args, &block)
  #   puts ["taaab->", name].inspect
  #   @items << Avo::Tab.new(name: name)
  # end

  # Fetch the tab
  def build
    @tab
  end
end

class Avo::PanelBuilder
  class << self
    def parse_block(**args, &block)
      Docile.dsl_eval(new(**args), &block).build
    end
  end

  delegate :add_tool, to: ::Avo::Services::DslService
  # delegate :add_field, to: ::Avo::Services::DslService

  attr_reader :items_index

  def initialize(name: nil, **args)
    @panel = Avo::Panel.new(title: name, **args)

    @name = name
    @args = args
    @items = []
    @items_index = 0
  end

  def tool(klass, **args)
    # Do nothing. We don't accept tools in panels
    # add_tool(@panel.items, klass, **args)
    # @panel.items_index += 1
  end

  def field(field_name, **args, &block)
    field_parser = Avo::Dsl::FieldParser.new(id: field_name, order_index: @panel.items_index, **args, &block).parse

    if field_parser.valid?
      @panel.items << field_parser.instance
      @panel.items_index += 1
    end
  end

  # Fetch the tab
  def build
    @panel
  end
end

# class Avo::Concerns::Builder
#   class << self
#     def parse_block(**args, &block)
#       Docile.dsl_eval(Avo::Concerns::Builder.new(**args), &block).build
#     end
#   end

#   delegate :add_tool, to: ::Avo::Services::DslService
#   # delegate :add_field, to: ::Avo::Services::DslService

#   def initialize(name: nil, items: [], **args)
#     @tab = Avo::Tab.new(name: name, **args)

#     # @tab.name = name
#     # @tab.tools = items
#     @tab.fields_holder = []
#     @tab.items_index = 0
#     @tab.tools_holder = []
#   end

#   # Adds a link
#   def field(name, **args, &block)
#     puts ["B field->", name, args].inspect
#     # @tab.fields_holder << name
#     field_parser = Avo::Dsl::FieldParser.new(name: name, order_index: @tab.items_index, **args, &block).parse

#     @tab.fields_holder << field_parser.instance if field_parser.valid?
#     @tab.items_index += 1
#   end

#   # Adds a link
#   def tool(klass, **args)
#     add_tool @tab.tools_holder, klass, **args
#   end

#   # Fetch the tab
#   def build
#     @tab
#   end
# end

class Avo::Tab
  include Avo::Concerns::HasFields
  include Avo::Concerns::IsResourceItem

  class_attribute :view, default: :show

  delegate :view, to: :self

  attr_reader :name
  attr_accessor :items

  def initialize(name: nil)
    @name = name
    @items = []
  end

  def parse
    # spot fields that don't belong to a panel and add them to a panel
    # abort items.inspect
    new_items = []
    in_panel = false
    latest_panel = Avo::Panel.new
    last_item = nil

    items.each do |item|
      puts ["1->", item.class].inspect
      if item.is_field?
        if in_panel
          new_items << item
        else
          # Add to latest panel
          latest_panel.add_item item
          # new_items << item
        end
      else
        if last_item.present? && last_item.is_field?
          # Close the panel and add it to the new stack
          new_items << latest_panel
          in_panel = false
          latest_panel = Avo::Panel.new
        end
      # elsif item.is_panel?
        # new_items << item
      # elsif item.is_tool?
        new_items << item
      end
      last_item = item
    end

    # abort [new_items].inspect

    @items = new_items
    # @items
  end
end

class Avo::TabGroup
  include Avo::Concerns::HasFields
  include Avo::Concerns::IsResourceItem

  class_attribute :view, default: :show
  class_attribute :item_type, default: :tab_group

  delegate :view, to: :self

  attr_accessor :index
  attr_accessor :tabs

  def initialize(index: 0, tabs: [])
    @index = index
    @tabs = tabs
  end

  def turbo_frame_id
    "#{Avo::TabGroup.to_s.underscore} #{index}".parameterize
  end
end


class Avo::Panel
  attr_reader :title
  attr_reader :description
  attr_reader :items
  attr_accessor :items_index
  attr_accessor :is_base_panel

  class_attribute :item_type, default: :panel

  include Avo::Concerns::IsResourceItem

  def initialize(title: nil, description: nil, items: [], is_base_panel: false)
    @title = title
    @description = description
    @items = items
    @is_base_panel = is_base_panel

    @items_index = 0
  end

  def add_item(item)
    @items << item
  end
end
