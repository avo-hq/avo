module Avo
  module Actions
    class Action
      attr_accessor :name
      attr_accessor :component
      attr_accessor :default
      # attr_accessor :fields

      @@default = nil

      class << self
        @@fields = {}

        def fields(&block)
          @@fields[self] ||= []
          yield
        end

        def get_fields
          @@fields[self] or []
        end

        def add_field(action, field)
          @@fields[action].push field
        end

      #   def method_missing(method, *args, &block)
      #     klass = Avo::App.get_field_names[method.to_s]

      #     raise NoMethodError.new "undefined method '#{method}' for #{self}" unless klass.present?

      #     if block.present?
      #       field_class = klass::new(args[0], **args[1] || {}, &block)
      #     else
      #       field_class = klass::new(args[0], **args[1] || {})
      #     end

      #     t = field_class
      #     rr = field_class

      #     self.add_field(self, field_class)
      #   end
      end

      def initialize
        @name ||= 'Action'
        @component ||= 'action'
        @default ||= ''
        @fields ||= []
      end

      def render_response(model, resource)
        fields = get_fields.map { |field| field.fetch_for_action(model, resource) }

        {
          id: id,
          name: name,
          fields: fields,
          component: component,
          default: default_value,
          action_class: self.class.to_s,
        }
      end

      def id
        self.class.name.underscore.gsub '/', '_'
      end

      def get_fields
        self.class.get_fields
      end
    end
  end
end
