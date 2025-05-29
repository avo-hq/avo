class Avo::Resources::Course::Link < Avo::BaseResource
  self.title = :link
  self.includes = [:course]
  self.search = {
    query: -> { query.ransack(id_eq: params[:q], link_cont: params[:q], m: "or").result(distinct: false) }
  }

  def display_fields
    field :id, as: :id
    field :link, as: :text, help: "Hehe. Something helpful."
    field :course, as: :belongs_to, searchable: true

    field :visits, as: :has_many, use_resource: Avo::Resources::Course::Link::Visit
  end

  def form_fields
    display_fields
    field :enable_course, as: :boolean, html: {
      edit: {
        input: {
          data: {
            action: "resource-edit#disable",
            resource_edit_disable_target_param: "courseBelongsToWrapper"
          }
        }
      }
    }
  end
end
