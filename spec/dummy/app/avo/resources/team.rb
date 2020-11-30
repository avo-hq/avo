module Avo
  module Resources
    class Team < Resource
      def initialize
        @title = :name
        @search = [:id, :name]
      end

      fields do
        id
        text :name
        textarea :description, rows: 5, readonly: false, hide_on: :index, format_using: -> (value) { value.to_s.truncate 30 }, default: 'This team is wonderful!', nullable: true, null_values: ['0', '', 'null', 'nil']

        number :members_count do |model|
          model.members.count
        end

        has_one :admin
        has_many :members
      end

      use_filter Avo::Filters::MembersFilter
    end
  end
end
