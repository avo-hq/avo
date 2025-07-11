class ResourceTableComponentPreview < Lookbook::Preview
  include ::ApplicationHelper
  include ::Avo::ApplicationHelper
  # include Rails.application.routes.url_helpers

  delegate :helpers, to: :view_context


  def standard
    view = Avo::ViewInquirer.new("index")
    resource_class = Avo::Resources::ResourceManager.build.get_resource_by_name("user")
    records = User.first(12)
    resources = records.map { |record| resource_class.new(record:, view:) }
    resource = resources.last

    render Avo::Views::ResourceIndexComponent.new(resources:, resource:)
  end
end
