class ProjectResource < Avo::BaseResource
  self.title = :name
  self.search_query = -> do
    scope.ransack(id_eq: params[:q], name_cont: params[:q], country_cont: params[:q], m: "or").result(distinct: false)
  end
  self.includes = :users
  self.unscoped_queries_on_index = true

  field :id, as: :id, link_to_resource: true
  field :name, as: :text, required: true, as_label: true, sortable: true
  field :progress, as: :progress_bar, value_suffix: "%", display_value: true
  field :status, as: :status, failed_when: ['closed', :rejected, :failed, 'user_reject'], loading_when: ['loading', :running, :waiting, 'Hold On'], nullable: true
  field :stage,
    as: :select,
    hide_on: [:show, :index],
    enum: ::Project.stages,
    placeholder: "Choose the stage",
    display_value: true,
    include_blank: false
  field :stage, as: :badge, options: {info: ["Discovery", "Idea"], success: "Done", warning: "On hold", danger: "Cancelled", neutral: "Drafting"}
  field :country,
    as: :country,
    index_text_align: :left,
    include_blank: "No country"
  field :users_required, as: :number, min: 10, max: 1000000, step: 1, index_text_align: :right
  field :started_at, as: :date_time, name: "Started", time_24hr: true, nullable: true,
    relative: true,
    timezone: "EET",
    format: "MMMM dd, y HH:mm:ss z"
  field :description, as: :markdown, height: "350px"
  field :files, as: :files, translation_key: "avo.field_translations.files", view_type: :list, stacked: false, hide_view_type_switcher: false
  field :meta, as: :key_value, key_label: "Meta key", value_label: "Meta value", action_text: "New item", delete_text: "Remove item", disable_editing_keys: false, disable_adding_rows: false, disable_deleting_rows: false

  field :users, as: :has_and_belongs_to_many
  field :comments, as: :has_many, searchable: true
  field :reviews, as: :has_many

  field :files_attachments, as: :has_many

  action ExportCsv

  # filter PeopleFilter
  # filter People2Filter
  # filter FeaturedFilter
  # filter MembersFilter
end
