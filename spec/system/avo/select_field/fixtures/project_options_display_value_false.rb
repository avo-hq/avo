module Avo
  module Resources
    class Project < Resource
      def configure
        @title = :name
        @search = [:name, :id]
      end

      def fields(request)
        f.select :country, options: { 'Romania': 'RO', 'Canada': 'CA', 'India': 'IN' }, display_value: false
      end
    end
  end
end
