module Avo
  module Resources
    class <%= class_name %> < Resource
      def initialize
        @title = :id
        @search = :id
      end

      fields do
        id
      end
    end
  end
end
