class TeamResource < Avo::BaseResource
  self.title = :name
  self.search = [:id, :name]
  self.includes = :admin

  fields do |f|
    f.id
    f.text :name
    f.text :url
    f.external_image :logo do |model|
      if model.url
        "//logo.clearbit.com/#{URI.parse(model.url).host}?size=180"
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

  grid do |cover, title, body|
    cover.external_image :logo, link_to_resource: true do |model|
      if model.url.present?
        "//logo.clearbit.com/#{URI.parse(model.url).host}?size=180"
      end
    end
    title.text :name, link_to_resource: true
    body.text :url
  end

  filters do |filter|
    filter.use MembersFilter
  end
end
