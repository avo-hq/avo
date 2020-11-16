module Avo
  module Resources
    class <%= class_name %> < Resource
      def initialize
        @title = :id
        @search = :id<%= generate_initializer %>
      end

      fields do
        id<%= generate_fields %>
      end
    end
  end
end
