module Avo
  class GridCollector
    include Avo::Concerns::HasFields

    attr_accessor :cover_field
    attr_accessor :title_field
    attr_accessor :body_field

    def initialize
      @cover_field = nil
      @title_field = nil
      @body_field = nil
    end

    def cover(field_name, as:, **args, &block)
      field_parser = Avo::Dsl::FieldParser.new(id: field_name, as: as, order_index: items_index, **args, &block).parse
      self.cover_field = field_parser.instance if field_parser.valid?
    end

    def title(field_name, as:, **args, &block)
      field_parser = Avo::Dsl::FieldParser.new(id: field_name, as: as, order_index: items_index, **args, &block).parse
      self.title_field = field_parser.instance if field_parser.valid?
    end

    def body(field_name, as:, **args, &block)
      field_parser = Avo::Dsl::FieldParser.new(id: field_name, as: as, order_index: items_index, **args, &block).parse
      self.body_field = field_parser.instance if field_parser.valid?
    end

    def hydrate(model:, view:, resource:)
      cover_field.hydrate(model: model, view: view, resource: resource) if cover_field.present?
      title_field.hydrate(model: model, view: view, resource: resource) if title_field.present?
      body_field.hydrate(model: model, view: view, resource: resource) if body_field.present?

      self
    end

    def blank?
      title_field.blank?
    end
  end
end
