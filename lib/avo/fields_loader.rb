class Avo::FieldsLoader
  attr_accessor :bag

  def initialize
    @bag = []
  end

  def add_field(field)
    @bag.push field
  end

  def method_missing(method, *args, &block)
    matched_field = Avo::App.fields.find do |field|
      field[:name].to_s == method.to_s
    end

    if matched_field.present? and matched_field[:class].present?
      klass = matched_field[:class]

      if block.present?
        field = klass::new(args[0], **args[1] || {}, &block)
      else
        field = klass::new(args[0], **args[1] || {})
      end

      add_field field
    end
  end
end
