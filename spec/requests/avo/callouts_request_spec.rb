require "rails_helper"

RSpec.describe "Resource callouts", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:project) { create :project, name: "Review launch" }

  before { login_as admin_user }

  around do |example|
    project_callouts = Avo::Resources::Project.callouts
    comment_callouts = Avo::Resources::Comment.callouts
    example.run
  ensure
    Avo::Resources::Project.callouts = project_callouts
    Avo::Resources::Comment.callouts = comment_callouts
  end

  def callouts
    Nokogiri::HTML(response.body).css(".callouts > .callout")
  end

  it "renders nothing when the resource has no callouts" do
    Avo::Resources::Project.callouts = nil

    get "/admin/resources/projects"

    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).css(".callouts")).to be_empty
  end

  it "renders the callouts above the records on every view of the resource" do
    Avo::Resources::Project.callouts = [
      {type: :warning, title: "Heads up", body: "Projects sync every night."}
    ]

    ["", "/new", "/#{project.to_param}", "/#{project.to_param}/edit"].each do |path|
      get "/admin/resources/projects#{path}"

      expect(response).to have_http_status(:ok)
      expect(callouts.size).to eq(1)
      expect(callouts.first["class"]).to include("callout--warning")
      expect(callouts.first.at_css(".callout__title").text).to eq("Heads up")
      expect(callouts.first.at_css(".callout__body").text).to eq("Projects sync every night.")
      expect(callouts.first.at_css(".callout__body").ancestors("form")).to be_empty
    end
  end

  it "evaluates blocks with the record, resource and view" do
    Avo::Resources::Project.callouts = [
      {
        type: -> { (record.name == "Review launch") ? :error : :info },
        title: -> { "#{resource.class} on #{view}" },
        body: -> { tag.strong(record.name) },
        icon: -> { "tabler/outline/flag" },
        url: -> { main_app.root_path(project: record.id) },
        target: -> { :_blank }
      }
    ]

    get "/admin/resources/projects/#{project.to_param}"

    callout = callouts.first
    expect(callout.name).to eq("a")
    expect(callout["class"]).to include("callout--error", "callout--link")
    expect(callout["href"]).to eq("/?project=#{project.id}")
    expect(callout["target"]).to eq("_blank")
    expect(callout.at_css(".callout__title").text).to eq("Avo::Resources::Project on show")
    expect(callout.at_css(".callout__body strong").text).to eq("Review launch")
  end

  it "escapes bodies that aren't marked as safe" do
    Avo::Resources::Project.callouts = [
      {title: "Unsafe", body: -> { "<script>alert('#{record.name}')</script>" }}
    ]

    get "/admin/resources/projects/#{project.to_param}"

    expect(callouts.first.at_css(".callout__body script")).to be_nil
    expect(callouts.first.at_css(".callout__body").text).to eq("<script>alert('Review launch')</script>")
  end

  it "shows only the callouts whose visible block allows the current view" do
    Avo::Resources::Project.callouts = [
      {title: "Everywhere"},
      {title: "Show only", visible: -> { view.show? }},
      {title: "Other project only", visible: -> { record&.name == "Other project" }}
    ]

    get "/admin/resources/projects"
    expect(callouts.map { |node| node.at_css(".callout__title").text }).to eq(["Everywhere"])

    get "/admin/resources/projects/#{project.to_param}"
    expect(callouts.map { |node| node.at_css(".callout__title").text }).to eq(["Everywhere", "Show only"])
  end

  it "keeps the form callouts when a create or an update fails" do
    Avo::Resources::Project.callouts = [
      {title: -> { "#{view}: #{record.errors[:name].join}" }, visible: -> { view.form? }}
    ]

    post "/admin/resources/projects", params: {project: {name: ""}}

    expect(response).to have_http_status(422)
    expect(callouts.first.text).to include("new: can't be blank")

    put "/admin/resources/projects/#{project.to_param}", params: {project: {name: ""}}

    expect(response).to have_http_status(422)
    expect(callouts.first.text).to include("edit: can't be blank")
  end

  it "renders a custom component with every resolved option" do
    stub_const("ProjectCalloutComponent", Class.new(Avo::CalloutComponent) do
      def call
        tag.div("#{@type}: #{@title} / #{@body} / #{@resource.record.name}", class: "callout project-callout")
      end
    end)
    Avo::Resources::Project.callouts = [
      {type: :success, title: "Done", body: -> { record.name }, component: "ProjectCalloutComponent"}
    ]

    get "/admin/resources/projects/#{project.to_param}"

    expect(callouts.first["class"]).to eq("callout project-callout")
    expect(callouts.first.text).to eq("success: Done / Review launch / Review launch")
  end

  it "keeps the resource's callouts off its association panels" do
    Avo::Resources::Comment.callouts = [{title: "Comment callout"}]
    post_record = create :post

    get "/admin/resources/posts/#{post_record.to_param}/comments?turbo_frame=has_many_field_show_comments"

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include("Comment callout")

    get "/admin/resources/comments"

    expect(callouts.map(&:text).join).to include("Comment callout")
  end

  it "keeps the callouts out of a form opened in a modal" do
    Avo::Resources::Project.callouts = [{title: "Project callout"}]

    get "/admin/resources/projects/new", params: {via_belongs_to_resource_class: "Avo::Resources::User"}

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include("Project callout")
  end

  it "raises on an unknown type" do
    Avo::Resources::Project.callouts = [{type: :danger, title: "Wrong"}]

    expect { get "/admin/resources/projects" }.to raise_error(ActionView::Template::Error, /Unknown callout type :danger.*info, success, warning, error/)
  end
end
