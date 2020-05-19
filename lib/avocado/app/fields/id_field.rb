require_relative './field'

module Avocado
  module Fields
    class IdField < Field
      include IsReadonly

      @defaults = {
        readonly: true,
        sortable: true,
        component: 'id-field'
      }
    end
  end
end
