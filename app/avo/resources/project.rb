module Avo
  module Resources
    class Project < Resource
      def initialize
        @title = :id
        @search = :id
      end

      fields do
        id
        text :name
        text :status
        select :stage, enum: ::Project.stages
        currency :budget
        country :country
        number :users_required
        datetime :started_at
        code :meta
        textarea :description
      end
    end
  end
end
