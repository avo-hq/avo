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
    card do
      field :id, as: :id
      field :body, as: :textarea, copyable: true, default: -> { "#{parent.first_name}'s comment" if parent.is_a?(User) }
      field :tiny_name, as: :text, only_on: :index
      field :posted_at,
        width: 50,
        as: :date_time,
        picker_format: "Y-m-d H:i:S",
        format: "cccc, d LLLL yyyy, HH:mm ZZZZ" # Wednesday, 10 February 1988, 16:00 GMT
      with_options width: 50 do
        field :user, as: :belongs_to, use_resource: Avo::Resources::CompactUser, link_to_record: true
      end
      field :commentable, as: :belongs_to, polymorphic_as: :commentable, types: [::Post, ::Project]
      field :test, stacked: true, width: 33 do
        "test1"
      end
      field :test2, stacked: true, width: 33 do
        "test2"
      end
      field :test2, stacked: true, width: 33 do
        "test3"
      end
      # field :test3 do
      #   "test"
      # end
      # field :test4 do
      #   "test"
      # end

      field :key_value, as: :key_value
    end
  end

  def filters
    filter Avo::Filters::CommentBodyFilter
  end
end
