module Avocado
  module Resources
    class <%= class_name %> < Resource
      def initialize
        @title = :id
        @search = :id
      end

      fields do
        id :ID
      end
    end
  end
end
