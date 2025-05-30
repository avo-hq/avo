class Avo::Resources::Comment < Avo::BaseResource
  self.title = :tiny_name
  self.includes = [:user, :commentable]
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], body_cont: params[:q], m: "or").result(distinct: false) }
  }

  self.record_selector = false

  self.after_create_path = :index
  self.after_update_path = :index

  def fields
    main_panel do
      field :id, as: :id
      field :body, as: :textarea, copyable: true
      field :tiny_name, as: :text, only_on: :index
      field :posted_at,
        as: :date_time,
        picker_format: "Y-m-d H:i:S",
        format: "cccc, d LLLL yyyy, HH:mm ZZZZ" # Wednesday, 10 February 1988, 16:00 GMT
      cluster divider: true do
        with_options stacked: true do
          field :user, as: :belongs_to, use_resource: Avo::Resources::CompactUser, link_to_record: true
          field :commentable, as: :belongs_to, polymorphic_as: :commentable, types: [::Post, ::Project]
        end
      end
    end
  end

  def filters
    filter Avo::Filters::CommentBodyFilter
  end
end
