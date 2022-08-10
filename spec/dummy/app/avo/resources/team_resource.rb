class TeamResource < Avo::BaseResource
  self.title = :name
  self.includes = [:admin, :team_members]
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false)
  end

  field :id, as: :id
  field :name, as: :text, sortable: true
  field :url, as: :text
  field :logo, as: :external_image, as_avatar: :rounded do |model|
    if model.url
      "//logo.clearbit.com/#{URI.parse(model.url).host}?size=180"
    end
  end
  field :color, as: ::ColorPickerField
  field :invalid, as: :invalid_field
  field :description,
    as_description: true,
    as: :textarea,
    rows: 5,
    readonly: false,
    hide_on: :index,
    format_using: ->(value) { value.to_s.truncate 30 },
    default: "This is a wonderful team!",
    nullable: true,
    null_values: ["0", "", "null", "nil"]

  field :members_count, as: :number do |model|
    model.team_members.length
  end

  field :memberships,
    as: :has_many,
    searchable: true,
    attach_scope: -> do
      query.where.not(user_id: parent.id).or(query.where(user_id: nil))
    end

  field :admin, as: :has_one
  field :team_members, as: :has_many, through: :memberships
  field :reviews, as: :has_many

  grid do
    cover :logo, as: :external_image, link_to_resource: true do |model|
      if model.url.present?
        "//logo.clearbit.com/#{URI.parse(model.url).host}?size=180"
      end
    end
    title :name, as: :text, link_to_resource: true
    body :url, as: :text
  end

  filter MembersFilter
  filter NameFilter

  action DummyAction
end
