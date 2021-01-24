module Avo
  module FieldsLoader
    # def fields(&block)
    #   yield fields_loader
    # end
    # # @@fields_loader |= Loader.new self

    # def fields_loader
    #   puts ['fields_loader->', self].inspect
    #   # @@fields_loader ||= Loader.new self
    #   @@fields_loader = Loader.new self
    # end

    # def fields_loader=(field)
    #   puts ['fields_loader=->', self].inspect
    #   @@fields_loader
    # end

    # def get_fields(resource_class)
    #   @@fields_loader.get_fields_bag(resource_class)
    # end

    class Loader
      attr_accessor :fields_bag
      attr_accessor :resource_class

      # def initialize(resource_class)
      def initialize
        # @resource_class = resource_class
        # puts ['Loader.initialize', @fields_bag].inspect
        @fields_bag = []
      end

      def method_missing(method, *args, &block)
        # puts ['method_missing->', method, args, 'self.fields_bag.keys.count'].inspect
        matched_fields = Avo::App.fields.select do |field|
          field[:name].to_s == method.to_s
        end

        # puts [matched_fields].inspect

        if matched_fields.present? and matched_fields.first[:class].present?
          klass = matched_fields.first[:class]

          if block.present?
            field = klass::new(args[0], **args[1] || {}, &block)
          else
            field = klass::new(args[0], **args[1] || {})
          end
          # puts ['before add_field', field].inspect
          add_field field
        end

        def add_field(field)
          # @fields_bag[resource_class] ||= []
          # puts ['add_field->', resource_class, field.class, @fields_bag[resource_class].count].inspect
          # @fields_bag[resource_class].push field
          # puts ['after add_field->', resource_class, field.class, @fields_bag[resource_class].count].inspect
          # puts ['add_field->', resource_class, field.class].inspect
          @fields_bag.push field
        end

        def get_fields_bag
          # count = @fields_bag[resource_class].present? ? @fields_bag[resource_class].count : nil
          # puts ['get_fields_bag->', resource_class, count,  @fields_bag].inspect
          # @fields_bag[resource_class] || []
          count = @fields_bag.present? ? @fields_bag.count : nil
          # puts ['get_fields_bag->', resource_class, count, '@fields_bag'].inspect
          @fields_bag
        end
      end
    end
  end
end
