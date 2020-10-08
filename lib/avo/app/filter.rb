module Avo
  class Filter
    attr_accessor :name
    attr_accessor :component
    attr_accessor :default

    @@default = nil

    def initialize
      @name ||= 'Filter'
      @component ||= 'boolean-filter'
      @default ||= ''
    end

    def render_response
      {
        id: id,
        name: name,
        options: options,
        component: component,
        default: default_value,
        filter_class: self.class.to_s,
      }
    end

    def apply_query(request, query, value)
      value.symbolize_keys! if value.is_a? Hash

      self.apply(request, query, value)
    end

    def id
      self.class.name.underscore.gsub('/', '_')
    end

    # These methods helps us set a default value in the testing environment
    def default_value
      @@default || default
    end

    def self.set_default(value)
      @@default = value
    end
  end
end
