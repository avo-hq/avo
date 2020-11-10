module Avo
  module Resources
    class <%= class_name %> < Resource
      def initialize
        @title = :id
        @search = :id
        <% if !@model.nil? %>@model = <%= @model %><% end %>
      end

      fields do
        id
        <% if !@fields.empty?
        @fields.each do |fieldname, fieldoptions| %><%= fieldoptions[:field] %> :<%= fieldname %>
        <% end
        end %>
      end
    end
  end
end
