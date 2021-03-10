module Avo
  class Filter
    class_attribute :name, default: 'Filter'
    class_attribute :component, default: 'boolean-filter'
    class_attribute :default, default: ''

    def apply_query(request, query, value)
      value.symbolize_keys! if value.is_a? Hash

      self.apply(request, query, value)
    end

    def id
      self.class.name.underscore.gsub('/', '_')
    end
  end
end
