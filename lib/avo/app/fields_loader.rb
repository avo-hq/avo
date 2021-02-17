class Avo::FieldsLoader
  attr_accessor :bag

  def initialize
    @bag = []
  end

  def method_missing(method, *args, &block)
    matched_fields = Avo::App.fields.select do |field|
      field[:name].to_s == method.to_s
    end

    if matched_fields.present? and matched_fields.first[:class].present?
      klass = matched_fields.first[:class]

      if block.present?
        field = klass::new(args[0], **args[1] || {}, &block)
      else
        field = klass::new(args[0], **args[1] || {})
      end

      add_field field
    end

    def add_field(field)
      @bag.push field
    end
  end
end
