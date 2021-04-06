module Avo
  class GridCollector
    include FieldsCollector

    attr_accessor :cover_field
    attr_accessor :title_field
    attr_accessor :body_field

    def initialize
      @cover_field = nil
      @title_field = nil
      @body_field = nil
    end

    def cover(field_name, as:, **args, &block)
      self.cover_field = parse_field(field_name, as: as, **args, &block)
    end

    def title(field_name, as:, **args, &block)
      self.title_field = parse_field(field_name, as: as, **args, &block)
    end

    def body(field_name, as:, **args, &block)
      self.body_field = parse_field(field_name, as: as, **args, &block)
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
