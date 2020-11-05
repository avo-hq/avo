module Avo
  module Resources
    class <%= class_name %> < Resource
      def initialize
        @title = :id
        @search = :id
      end

      fields do
        id
        <% if @fieldsHash.present?
        @fieldsHash.each do |fieldname, fieldtype| %><%= fieldtype %> :<%= fieldname %>
        <% end
        end %>
      end
    end
  end
end
