module Avo
  module Resources
    class Team < Resource
      def configure
        @title = :name
        @search = [:id, :name]
        @includes = :admin
      end

      def fields(request)
        f.id
        f.text :name
        f.text :url
        f.external_image :logo do |model|
          if model.url
            "//logo.clearbit.com/#{URI.parse(model.url).host}"
          else
            nil
          end
        end
        f.textarea :description, rows: 5, readonly: false, hide_on: :index, format_using: -> (value) { value.to_s.truncate 30 }, default: 'This team is wonderful!', nullable: true, null_values: ['0', '', 'null', 'nil']

        f.number :members_count do |model|
          model.members.count
        end

        f.has_one :admin
        f.has_many :members, through: :memberships
      end

      def filters(request)
        filter.use Avo::Filters::MembersFilter
      end
    end
  end
end
