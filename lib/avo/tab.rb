class Avo::Tab
  include Avo::Concerns::HasTools
  include Avo::Concerns::HasFields

  class_attribute :view, default: :show

  delegate :view, to: :self

  attr_reader :name
  attr_accessor :tools_holder
  attr_accessor :fields_holder

  def initialize(name: nil)
    @name = name
    @tools_holder = []
    @fields_holder = []
  end

  def tools
    tools_holder
  end
end
