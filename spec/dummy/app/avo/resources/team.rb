class Avo::Resources::Team < Avo::BaseResource
  self.includes = [:admin, :team_members, :locations]
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], name_cont: params[:q], m: "or").result(distinct: false) }
  }
  self.grid_view = {
    card: -> do
      {
        cover_url: record.url.present? ? "//logo.clearbit.com/#{URI.parse(record.url).host}?size=180" : nil,
        title: record.name,
        body: record.url
      }
    end
  }

  def fields
    main_panel do
      field :preview, as: :preview

      unless params[:hide_id]
        field :id, as: :id, filterable: true
      end
      field :name, as: :text, sortable: true, show_on: :preview, filterable: true, html: -> do
        index do
          wrapper do
            style do
              if record.color
                "color: #{record.color}"
              end
            end
          end
        end
      end
      field :logo, as: :external_image, hide_on: :show, as_avatar: :rounded do
        if record&.url
          "//logo.clearbit.com/#{URI.parse(record.url).host}?size=180"
        end
      rescue
        "nope"
      end
      field :created_at, as: :date_time, filterable: true
      field :color, as: :color_pickerrr, hide_on: :index, show_on: :preview
      field :invalid, as: :invalid_field
      field :description,
        as: :textarea,
        rows: 5,
        readonly: false,
        hide_on: :index,
        format_using: -> { value.to_s.truncate 30 },
        default: "This is a wonderful team!",
        filterable: true,
        nullable: true,
        null_values: ["0", "", "null", "nil"],
        show_on: :preview

      field :members_count, as: :number do
        record.team_members.length
      end

      sidebar do
        field :url, as: :text
        field :created_at, as: :date_time, hide_on: :forms
        field :logo, as: :external_image, as_avatar: :rounded do
          if record&.url
            "//logo.clearbit.com/#{URI.parse(record.url).host}?size=180"
          end
        end
      end
    end

    field :memberships,
      as: :has_many,
      searchable: true,
      filterable: true,
      linkable: true,
      reloadable: true,
      attach_scope: -> do
        query.where.not(user_id: parent.id).or(query.where(user_id: nil))
      end

    field :admin, as: :has_one, linkable: true
    field :team_members,
      as: :has_many,
      through: :memberships,
      linkable: true,
      reloadable: true
    field :reviews, as: :has_many,
      reloadable: -> {
        current_user.is_admin?
      }

    if params[:show_location_field] == "1"
      # Example for error message when resource is missing
      field :locations, as: :has_many
    end
  end

  def filters
    filter Avo::Filters::MembersFilter
    filter Avo::Filters::NameFilter
  end

  def actions
    action Avo::Actions::Sub::DummyAction
  end
end
