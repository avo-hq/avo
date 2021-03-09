module Avo
  class Filter
    attr_accessor :name
    attr_accessor :component
    attr_accessor :default

    def initialize
      @name ||= 'Filter'
      @component ||= 'boolean-filter'
      @default ||= ''
    end

    def apply_query(request, query, value)
      value.symbolize_keys! if value.is_a? Hash

      self.apply(request, query, value)
    end

    def id
      self.class.name.underscore.gsub('/', '_')
    end
  end
end
