class Avo::Resources::Project < Avo::BaseResource
  self.title = :name

  self.search = {
    query: -> {
      query.ransack(id_eq: params[:q], name_cont: params[:q], country_cont: params[:q], m: "or").result(distinct: false)
    }
  }
  self.includes = [:users, files_attachments: :blob]
  self.index_query = -> {
    query.unscoped
  }

  def fields
    field :id, as: :id, link_to_record: true
    field :status,
      as: :status,
      failed_when: ["closed", :rejected, :failed, "user_reject"],
      loading_when: ["loading", :running, :waiting, "Hold On"],
      success_when: ["Done"],
      nullable: true,
      filterable: true,
      summarizable: true
    field :name, as: :text, required: true, sortable: true, default: "New project default name"
    field :progress,
      as: :progress_bar,
      value_suffix: "%",
      display_value: true,
      visible: -> do
        # conditionally hiding the fields we can test that it's not going to break the table layout
        resource.view.form? || resource.record.progress&.positive?
      end
    field :stage,
      as: :select,
      hide_on: :display,
      enum: ::Project.stages,
      placeholder: "Choose the stage",
      display_value: true,
      include_blank: false
    field :stage,
      as: :badge,
      options: {
        info: ["Discovery", "Idea"],
        success: :Done,
        warning: "On hold",
        danger: :Cancelled,
        neutral: :Drafting
      },
      filterable: true,
      sortable: true,
      summarizable: true
    field :country,
      as: :country,
      include_blank: "No country",
      filterable: true,
      summarizable: true
    field :users_required, as: :number, min: 10, max: 1000000, step: 1, html: {index: {wrapper: {classes: "text-right"}}}, summarizable: true
    field :started_at, as: :date_time, name: "Started", time_24hr: true, nullable: true,
      relative: true,
      timezone: "EET",
      format: "MMMM dd, y HH:mm:ss z"
    field :description, as: :markdown, height: "350px"
    field :files,
      as: :files,
      translation_key: "avo.field_translations.files",
      view_type: :list, stacked: false,
      hide_view_type_switcher: false
    field :meta, as: :key_value, key_label: "Meta key", value_label: "Meta value", action_text: "New item", delete_text: "Remove item", disable_editing_keys: false, disable_adding_rows: false, disable_deleting_rows: false, html: -> do
      show do
        wrapper { classes("spoon") }
      end
    end

    field :users, as: :has_and_belongs_to_many
    field :comments, as: :has_many, searchable: true
    field :even_reviews, as: :has_many, for_attribute: :reviews, scope: -> { query.where("reviews.id % 2 = ?", "0") }
    field :reviews, as: :has_many
    field :files_attachments, as: :has_many
  end

  def actions
    action Avo::Actions::ExportCsv
  end

  def filters
    # filter PeopleFilter
    # filter People2Filter
    # filter FeaturedFilter
    # filter MembersFilter
  end
end
