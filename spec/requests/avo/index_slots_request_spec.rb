require "rails_helper"

RSpec.describe "Resource index slots", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }

  before { login_as admin_user }

  around do |example|
    project_slots = Avo::Resources::Project.index_slots
    user_slots = Avo::Resources::User.index_slots
    post_slots = Avo::Resources::Post.index_slots
    replacements = [Avo::Resources::Project, Avo::Resources::User, Avo::Resources::Post].to_h do |resource|
      [resource, resource.index_slot_replacements]
    end
    loading = Avo::Resources::Project.index_view_loading
    example.run
  ensure
    Avo::Resources::Project.index_slots = project_slots
    Avo::Resources::User.index_slots = user_slots
    Avo::Resources::Post.index_slots = post_slots
    replacements.each { |resource, slots| resource.index_slot_replacements = slots }
    Avo::Resources::Project.index_view_loading = loading
  end

  it "places additions around the default table without replacing its title, controls or pagination" do
    create :project, name: "Launch project"
    %i[before_cards after_cards before_header after_header before_title after_title
      before_toolbar after_toolbar before_collection after_collection
      before_records after_records before_pagination after_pagination].each do |position|
      Avo::Resources::Project.index_slot(position) { tag.span(position, data: {test_slot: position}) }
    end

    get "/admin/resources/projects"

    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    expect(document.css("[data-test-slot]").map { |node| node["data-test-slot"] }).to eq(%w[
      before_cards after_cards before_header before_title after_title after_header
      before_toolbar after_toolbar before_collection before_records after_records
      before_pagination after_pagination after_collection
    ])
    expect(document.at_css(".header__title").text).to match(/before_title\s*Projects\s*after_title/)
    expect(document.at_css(".header__controls").text).to include("Create")
    expect(document.at_css("table").text).to include("Launch project")
    expect(document.at_css("#projects_list").text).to match(/before_records.*Launch project.*after_records.*before_pagination.*1 record.*after_pagination/m)
    %w[before_records after_records].each do |position|
      expect(document.at_css("[data-test-slot='#{position}']").parent["class"]).to include("card")
    end
    %w[before_collection after_collection].each do |position|
      expect(document.at_css("[data-test-slot='#{position}']").parent["id"]).to eq("projects_list")
    end
  end

  it "renders partials and components with request context, in registration order, escaping plain strings" do
    Avo::Resources::Project.index_slot(:after_header) do
      render Avo::UI::PanelHeaderComponent.new(title: "#{resource.plural_name} for #{current_user.email}")
    end
    Avo::Resources::Project.view_slot(:index, :after_header) { render partial: "avo/partials/slot_test", locals: {label: params[:label]} }
    Avo::Resources::Project.index_slot(:after_header) { "<script>unsafe</script>" }
    Avo::Resources::Project.index_slot(:after_header) { nil }
    Avo::Resources::Project.index_slot(:collection, replace: true) do
      render partial: "avo/partials/slot_wrapper", locals: {default_content: default_content}
    end
    resolver = ActionView::FixtureResolver.new(
      "avo/partials/_slot_test.html.erb" => "<strong><%= label %></strong>",
      "avo/partials/_slot_wrapper.html.erb" => '<section id="partial-default"><%= default_content.call %></section>'
    )
    original_paths = Avo::BaseController.view_paths
    Avo::BaseController.prepend_view_path(resolver)

    get "/admin/resources/projects", params: {label: "Team summary"}

    expect(response).to have_http_status(:ok)
    expect(response.body).to match(/Projects for #{Regexp.escape(admin_user.email)}.*<strong>Team summary<\/strong>.*&lt;script&gt;unsafe&lt;\/script&gt;/m)
    expect(response.body).not_to include("<script>unsafe</script>")
    expect(Nokogiri::HTML(response.body).at_css("#partial-default").text).to include("No record found")

    create :project, name: "Wrapped project"
    get "/admin/resources/projects", params: {label: "Team summary"}

    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    expect(document.at_css("#partial-default table").text).to include("Wrapped project")
    expect(document.css("table").size).to eq(1)
  ensure
    Avo::BaseController.view_paths = original_paths if original_paths
  end

  it "places grid additions inside the list frame alongside its paginator" do
    Avo::Resources::User.view_slot(:index, :before_collection) { tag.p("Collection starts") }
    Avo::Resources::User.index_slot(:before_records) { tag.p("Grid starts: #{view_type}") }
    Avo::Resources::User.index_slot(:after_records) { tag.p("Grid ends") }
    Avo::Resources::User.index_slot(:after_pagination) { tag.p("Page #{pagy.page}") }
    Avo::Resources::User.index_slot(:after_collection) { tag.p("Collection ends") }
    %i[collection records pagination].each do |region|
      Avo::Resources::User.index_slot(region, replace: true) do
        tag.div(default_content.call, data: {region: region})
      end
    end

    get "/admin/resources/users", params: {view_type: "grid"}

    expect(response).to have_http_status(:ok)
    frame = Nokogiri::HTML(response.body).at_css("#users_list")
    expect(frame.text).to match(/Collection starts.*Grid starts: grid.*#{Regexp.escape(admin_user.name)}.*Grid ends.*Page 1.*Collection ends/m)
    expect(frame.at_css('[data-region="collection"] [data-region="records"] .grid-wrapper').text).to include(admin_user.name)
    expect(frame.at_css('[data-region="collection"] [data-region="pagination"] .pagination')).to be_present
  end

  it "wraps all default regions while preserving their nested controls and records" do
    create :project, name: "Launch project"
    %i[cards header title toolbar collection records pagination].each do |region|
      Avo::Resources::Project.index_slot(region, replace: true) do
        content_tag((region == :title) ? :span : :div, data: {region: region}) do
          default_content.call
        end
      end
    end

    get "/admin/resources/projects"

    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    expect(document.css("[data-region]").map { |node| node["data-region"] })
      .to eq(%w[cards header title toolbar collection records pagination])
    expect(document.at_css('[data-region="header"] [data-region="title"]').text.strip).to eq("Projects")
    expect(document.at_css('[data-region="header"] .header__controls').text).to include("Create")
    expect(document.at_css('[data-region="toolbar"] input[name="q"]')).to be_present
    expect(document.at_css('[data-region="collection"] [data-region="records"] table').text).to include("Launch project")
    expect(document.at_css('[data-region="collection"] [data-region="pagination"]').text).to include("1 record")
    expect(document.css("#projects_list").size).to eq(1)
  end

  it "captures the default only once per render without caching it across requests" do
    renders = 0
    Avo::Resources::Project.index_slot(:title, replace: true) { "Title #{renders += 1}" }
    Avo::Resources::Project.index_slot(:header, replace: true) do
      content = default_content.call
      default_content.call
      tag.section(content, id: "wrapped-header")
    end

    2.times do |index|
      get "/admin/resources/projects"

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML(response.body)
      expect(document.at_css("#wrapped-header .header__title").text.strip).to eq("Title #{index + 1}")
      expect(document.css("#wrapped-header .header").size).to eq(1)
    end
  end

  it "computes a built-in title only when its replacement preserves it, and only once" do
    components = Avo::Resources::Project.components
    title_source = -> { raise "The replaced title must not be computed" }
    custom_index = Class.new(Avo::Views::ResourceIndexComponent) do
      define_method(:title) { title_source.call }
    end
    stub_const("Avo::Views::SlotTitleIndexComponent", custom_index)
    Avo::Resources::Project.components = components.merge(resource_index_component: custom_index)
    preserve_default = false
    Avo::Resources::Project.index_slot(:title, replace: true) do
      tag.span(preserve_default ? default_content.call : "Replacement title", id: "lazy-title")
    end

    get "/admin/resources/projects"

    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).at_css("#lazy-title").text).to eq("Replacement title")

    sequence = 0
    title_source = -> { "Default title #{sequence += 1}" }
    preserve_default = true

    get "/admin/resources/projects"

    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).at_css("#lazy-title").text).to eq("Default title 1")
  ensure
    Avo::Resources::Project.components = components
  end

  it "skips defaults and nested hooks when replacing a header but retains its surrounding hooks" do
    Avo::Resources::Project.index_slot(:before_header) { tag.p("Before header") }
    Avo::Resources::Project.index_slot(:after_header) { tag.p("After header") }
    Avo::Resources::Project.index_slot(:before_title) { raise "Nested default was rendered" }
    Avo::Resources::Project.index_slot(:title, replace: true) { raise "Nested replacement was rendered" }
    Avo::Resources::Project.index_slot(:header, replace: true) { "<strong>Custom header</strong>" }

    get "/admin/resources/projects"

    expect(response).to have_http_status(:ok)
    expect(response.body).to match(/Before header.*&lt;strong&gt;Custom header&lt;\/strong&gt;.*After header/m)
    expect(Nokogiri::HTML(response.body).at_css(".header__controls")).to be_nil
  end

  it "hides a collection without removing its Turbo frame or its surrounding additions" do
    create :project
    Avo::Resources::Project.index_slot(:before_collection) { tag.p("Before collection") }
    Avo::Resources::Project.index_slot(:after_collection) { tag.p("After collection") }
    Avo::Resources::Project.index_slot(:records, replace: true) { raise "Hidden records were rendered" }
    Avo::Resources::Project.index_slot(:collection, replace: true) { nil }

    get "/admin/resources/projects"

    expect(response).to have_http_status(:ok)
    frame = Nokogiri::HTML(response.body).at_css("#projects_body_content #projects_list")
    expect(frame.text).to match(/Before collection.*After collection/m)
    expect(frame.at_css("table, .card__footer")).to be_nil
  end

  %i[collection records].each do |region|
    it "prepares table rows only when the #{region} replacement preserves them, and only once" do
      create :project, name: "Lazy project"
      components = Avo::Resources::Project.components
      prepare_row = -> { raise "Replaced table rows must not be prepared" }
      custom_row = Class.new(Avo::Index::TableRowComponent) do
        define_method(:initialize) do |**kwargs|
          @preparation = prepare_row.call
          super(**kwargs)
        end

        def merged_tr_attributes
          attributes = super
          attributes.merge(data: attributes[:data].merge(preparation: @preparation))
        end
      end
      stub_const("Avo::Index::SlotLazyTableRowComponent", custom_row)
      Avo::Resources::Project.components = components.merge("Avo::Index::TableRowComponent" => custom_row)
      preserve_default = false
      Avo::Resources::Project.index_slot(region, replace: true) do
        if preserve_default
          content = default_content.call
          default_content.call
          tag.section(content, id: "lazy-records")
        else
          tag.p("Replacement records", id: "lazy-records")
        end
      end

      get "/admin/resources/projects"

      expect(response).to have_http_status(:ok)
      expect(Nokogiri::HTML(response.body).at_css("#lazy-records").text).to eq("Replacement records")

      sequence = 0
      prepare_row = -> { sequence += 1 }
      preserve_default = true

      2.times do |index|
        get "/admin/resources/projects"

        expect(response).to have_http_status(:ok)
        rows = Nokogiri::HTML(response.body).css("#lazy-records tbody tr")
        expect(rows.size).to eq(1)
        expect(rows.first.text).to include("Lazy project")
        expect(rows.first["data-preparation"]).to eq((index + 1).to_s)
      end
    ensure
      Avo::Resources::Project.components = components
    end
  end

  it "replaces empty records inside a preserved collection without rendering pagination" do
    Avo::Resources::Project.view_slot(:index, :collection, replace: true) do
      tag.section(default_content.call, id: "custom-collection")
    end
    Avo::Resources::Project.index_slot(:records, replace: true) { tag.p("No projects yet", id: "custom-empty") }
    Avo::Resources::Project.index_slot(:pagination, replace: true) { raise "There is no paginator" }

    get "/admin/resources/projects"

    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).at_css("#projects_body_content #custom-collection #custom-empty").text)
      .to eq("No projects yet")
    expect(response.body).not_to include("No record found")
  end

  it "keeps record slots around the empty state without inventing pagination" do
    Avo::Resources::Project.index_slot(:before_collection) { tag.p("Collection starts") }
    Avo::Resources::Project.index_slot(:before_records) { tag.p("Before empty") }
    Avo::Resources::Project.index_slot(:after_records) { tag.p("After empty") }
    Avo::Resources::Project.index_slot(:after_collection) { tag.p("Collection ends") }
    Avo::Resources::Project.index_slot(:after_pagination) { raise "There is no paginator" }

    get "/admin/resources/projects"

    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).at_css("#projects_body_content").text)
      .to match(/Collection starts.*Before empty.*No record found.*After empty.*Collection ends/m)
  end

  it "refreshes record and pagination additions with live search and page changes" do
    create :project, name: "Alpha release"
    create :project, name: "Beta release"
    create :project, name: "Unrelated project"
    Avo::Resources::Project.index_slot(:before_records) do
      tag.p("Results: #{pagy.count}, page: #{pagy.page}", id: "result-summary")
    end
    Avo::Resources::Project.index_slot(:after_pagination) { tag.p("Page ends", id: "page-end") }
    Avo::Resources::Project.index_slot(:pagination, replace: true) do
      tag.div(safe_join([tag.p("Custom page #{pagy.page}"), default_content.call]), id: "custom-pagination")
    end

    get "/admin/resources/projects", params: {q: "release", per_page: 1, page: 2, sort_by: "name", sort_direction: "asc"},
      headers: {"Accept" => "text/vnd.turbo-stream.html", "X-Search-Request" => "resource-search-controller"}

    expect(response).to have_http_status(:ok)
    replacement = Nokogiri::HTML(response.body).at_css('turbo-stream[target="projects_body_content"] template')
    expect(replacement.at_css("#result-summary").text).to eq("Results: 2, page: 2")
    expect(replacement.at_css("#custom-pagination").text.tr("\u00a0", " ").squish).to include("Custom page 2", "2-2 of 2")
    expect(replacement.at_css("table").text).to include("Beta release")
    expect(replacement.at_css("table").text).not_to include("Alpha release", "Unrelated project")
    expect(replacement.at_css("#page-end").ancestors("turbo-frame").map { |node| node["id"] }).to include("projects_list")
  end

  it "defers data-dependent additions until the lazy index frame loads" do
    Avo::Resources::Project.index_view_loading = :lazy
    Avo::Resources::Project.index_slot(:after_header) { tag.p("Shell addition") }
    Avo::Resources::Project.index_slot(:toolbar, replace: true) { tag.p("Custom toolbar on page #{pagy.page}") }
    Avo::Resources::Project.index_slot(:before_records) do
      tag.p("#{resources.size} projects on page #{pagy.page}")
    end
    create :project

    get "/admin/resources/projects"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Shell addition")
    expect(response.body).not_to include("projects on page")
    expect(response.body).not_to include("Custom toolbar")

    get "/admin/resources/projects", headers: {"Turbo-Frame" => "projects_index"}
    expect(response).to have_http_status(:ok)
    frame = Nokogiri::HTML(response.body).at_css("#projects_index")
    expect(frame.text).to include("1 projects on page 1")
    expect(frame.text).to include("Custom toolbar on page 1")
    expect(frame.text).not_to include("Shell addition")
  end

  it "provides the parent context for association indexes" do
    create :post, user: admin_user, name: "Associated post"
    Avo::Resources::Post.index_slot(:before_records) do
      tag.p("#{parent_resource.singular_name}: #{parent_record.email}")
    end

    get "/admin/resources/users/#{admin_user.slug}/posts",
      params: {turbo_frame: "has_many_field_posts"},
      headers: {"Turbo-Frame" => "has_many_field_posts"}

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("User: #{admin_user.email}", "Associated post")
  end

  it "inherits additions without changing a parent or sibling resource" do
    parent = Class.new(Avo::BaseResource)
    child = Class.new(parent)
    sibling = Class.new(parent)
    [parent, child, sibling].each(&:abstract_resource!)
    parent.index_slot(:after_header) { tag.p("Shared") }
    child.index_slot(:after_header) { tag.p("Child only") }

    expect(parent.index_slots[:after_header].size).to eq(1)
    expect(sibling.index_slots[:after_header].size).to eq(1)
    expect(child.index_slots[:after_header].size).to eq(2)
  end

  it "lets children replace inherited content while their default remains Avo's built-in content" do
    parent = Class.new(Avo::BaseResource)
    stub_const("SlotParentResource", parent)
    parent.abstract_resource!
    parent.model_class = ::Project
    parent.index_slot(:records, replace: true) { tag.p("Parent content") }
    child = Class.new(parent)
    sibling = Class.new(parent)
    stub_const("SlotChildResource", child)
    stub_const("SlotSiblingResource", sibling)
    [child, sibling].each do |resource|
      resource.abstract_resource!
      resource.model_class = ::Project
    end
    child.index_slot(:records, replace: true) { tag.section(default_content.call, id: "child-default") }

    [parent, sibling, child].each do |resource|
      html = Avo::BaseController.render(
        Avo::ResourceListingComponent.new(resource: resource.new(view: :index), resources: []), layout: false
      )

      if resource == child
        expect(Nokogiri::HTML(html).at_css("#child-default").text).to include("No record found")
        expect(html).not_to include("Parent content")
      else
        expect(html).to include("Parent content")
        expect(html).not_to include("No record found")
      end
    end
  end

  it "rejects unknown positions and missing blocks when registering an addition" do
    expect { Avo::Resources::Project.view_slot(:unknown, :after_header) {} }
      .to raise_error(ArgumentError, /Unsupported slot view :unknown/)
    expect { Avo::Resources::Project.index_slot(:after_pagniation) {} }
      .to raise_error(ArgumentError, /Unknown index slot :after_pagniation/)
    expect { Avo::Resources::Project.index_slot(:after_header) }
      .to raise_error(ArgumentError, /requires a block/)
    expect { Avo::Resources::Project.index_slot(:title) {} }
      .to raise_error(ArgumentError, /Unknown index slot :title/)
    expect { Avo::Resources::Project.index_slot(:before_title, replace: true) {} }
      .to raise_error(ArgumentError, /Unknown index slot :before_title/)
    Avo::Resources::Project.index_slot(:title, replace: true) {}
    expect { Avo::Resources::Project.view_slot(:index, :title, replace: true) {} }
      .to raise_error(ArgumentError, /already has a replacement/)
  end
end
