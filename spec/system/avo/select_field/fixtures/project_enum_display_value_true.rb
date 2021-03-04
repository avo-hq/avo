module Avo
  module Resources
    class Project < Resource
      def configure
        @title = :name
        @search = [:name, :id]
      end

      def fields(request)
        f.select :stage, hide_on: [:index], enum: ::Project.stages, placeholder: 'Choose the stage', display_value: false
      end
    end
  end
end
