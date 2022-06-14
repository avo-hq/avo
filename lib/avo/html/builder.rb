class Avo::HTML::Builder
  class << self
    def parse_block(record: nil, resource: nil, &block)
      Docile.dsl_eval(Avo::HTML::Builder.new(record: record, resource: resource), &block).build
    end
  end

  attr_accessor :wrapper_stack
  attr_accessor :data_stack
  attr_accessor :style_stack
  attr_accessor :classes_stack
  attr_accessor :show_stack
  attr_accessor :edit_stack
  attr_accessor :index_stack
  attr_accessor :input_stack

  attr_accessor :record
  attr_accessor :resource

  delegate :root_path, to: Avo::App
  delegate :params, to: Avo::App
  delegate :current_user, to: Avo::App

  def initialize(record: nil, resource: nil)
    @wrapper_stack = {}
    @data_stack = {}
    @style_stack = ""
    @classes_stack = ""
    @show_stack = {}
    @edit_stack = {}
    @index_stack = {}
    @input_stack = {}

    @record = record
    @resource = resource
  end

  def get_stack(name = nil)
    # We don't have an edit component for new so we should use edit
    name = :edit if name == :new

    send "#{name}_stack"
  end

  def dig_stack(*names)
    value = get_stack names.shift

    if value.is_a? self.class
      value.dig_stack(*names)
    else
      value
    end
  end

  # payload or block
  def data(payload = nil, &block)
    assign_property :data, payload, &block
  end

  # payload or block
  def style(payload = nil, &block)
    assign_property :style, payload, &block
  end

  # payload or block
  def classes(payload = nil, &block)
    assign_property :classes, payload, &block
  end

  # Takes a block
  def wrapper(&block)
    capture_block :wrapper, &block
  end

  # Takes a block
  def input(&block)
    capture_block :input, &block
  end

  # Takes a block
  def show(&block)
    capture_block :show, &block
  end

  # Takes a block
  def edit(&block)
    capture_block :edit, &block
  end

  # Takes a block
  def index(&block)
    capture_block :index, &block
  end

  # Fetch the menu
  def build
    self
  end

  protected

  # Capture and parse the blocks for the nested structure
  def capture_block(property = nil, &block)
    send("#{property}_stack=", self.class.parse_block(record: record, resource: resource, &block).build)
  end

  # Parse the properties and assign them to the blocks
  def assign_property(property = :data, payload = nil, &block)
    value = if block.present?
      Avo::Hosts::RecordHost.new(block: block, record: record).handle
    else
      payload
    end

    send("#{property}_stack=", value)
  end
end
