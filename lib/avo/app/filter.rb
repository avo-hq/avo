module Avo
  class Filter
    class_attribute :name, default: 'Filter'
    class_attribute :component, default: 'boolean-filter'
    class_attribute :default, default: ''
    class_attribute :template, default: 'avo/base/select_filter'

    def apply_query(request, query, value)
      value.symbolize_keys! if value.is_a? Hash

      self.apply(request, query, value)
    end

    def id
      self.class.name.underscore.gsub('/', '_')
    end
  end
end
