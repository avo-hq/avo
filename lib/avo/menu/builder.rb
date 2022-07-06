class Avo::Menu::Builder
  class << self
    def parse_menu(&block)
      Docile.dsl_eval(Avo::Menu::Builder.new, &block).build
    end
  end

  delegate :context, to: ::Avo::App
  delegate :current_user, to: ::Avo::App
  delegate :params, to: ::Avo::App
  delegate :request, to: ::Avo::App
  delegate :root_path, to: ::Avo::App
  delegate :view_context, to: ::Avo::App

  def initialize(name: nil, items: [])
    @menu = Avo::Menu::Menu.new

    @menu.name = name
    @menu.items = items
  end

  # Adds a link
  def link(name, **args)
    @menu.items << Avo::Menu::Link.new(name: name, **args)
  end

  # Validates and adds a resource
  def resource(name, **args)
    name = name.to_s.singularize
    res = Avo::App.guess_resource(name)

    if res.present?
      @menu.items << Avo::Menu::Resource.new(resource: name, **args)
    end
  end
  alias_method :resources, :resource

  # Adds a dashboard
  def dashboard(dashboard, **args)
    @menu.items << Avo::Menu::Dashboard.new(dashboard: dashboard, **args)
  end

  # Adds a section
  def section(name = nil, **args, &block)
    @menu.items << Avo::Menu::Section.new(name: name, **args, items: self.class.parse_menu(&block).items)
  end

  # Adds a group
  def group(name = nil, **args, &block)
    @menu.items << Avo::Menu::Group.new(name: name, **args, items: self.class.parse_menu(&block).items)
  end

  # Add all the resources
  def all_resources(**args)
    Avo::App.resources_for_navigation.each do |res|
      resource res.model_class, **args
    end
  end

  # Add all the dashboards
  def all_dashboards(**args)
    Avo::App.dashboards_for_navigation.each do |dash|
      dashboard dash.id, **args
    end
  end

  # Add all the tools
  def all_tools(**args)
    Avo::App.tools_for_navigation.each do |tool|
      link tool.humanize, path: root_path(paths: [tool])
    end
  end

  # Fetch the menu
  def build
    @menu
  end
end
