require "rails_helper"

RSpec.describe "Resource show and form slots", type: :request do
  let(:admin_user) { create :user, roles: {admin: true} }
  let(:project) { create :project, name: "Review launch" }

  before { login_as admin_user }

  around do |example|
    attributes = %i[show edit new form].flat_map { |view| [:"#{view}_slots", :"#{view}_slot_replacements"] }
    registrations = attributes.to_h { |name| [name, Avo::Resources::Project.public_send(name)] }
    example.run
  ensure
    registrations.each { |name, value| Avo::Resources::Project.public_send(:"#{name}=", value) }
  end

  it "renders symmetric show hooks once, preserving fields, title and controls" do
    %i[cards body header title controls].each do |region|
      %i[before after].each do |side|
        position = :"#{side}_#{region}"
        Avo::Resources::Project.show_slot(position) { tag.span(position, data: {test_slot: position}) }
      end
    end
    Avo::Resources::Project.form_slot(:before_body) { raise "Show is not a form" }

    get "/admin/resources/projects/#{project.to_param}"

    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    expect(document.css("[data-test-slot]").map { |node| node["data-test-slot"] }).to eq(%w[
      before_cards after_cards before_body before_header before_title after_title
      before_controls after_controls after_header after_body
    ])
    expect(document.at_css(".header__title").text).to include("Review launch")
    expect(document.at_css(".header__controls").text).to include("Edit")
    expect(document.at_css("[data-field-id='name']").text).to include("Review launch")
  end

  it "combines shared and specific additions on both forms without leaking view-specific content" do
    Avo::Resources::Project.edit_slot(:before_title) { tag.span("Edit only", data: {test_slot: "edit"}) }
    Avo::Resources::Project.new_slot(:before_title) { tag.span("New only", data: {test_slot: "new"}) }
    Avo::Resources::Project.view_slot(:form, :before_title) { tag.span("Shared first", data: {test_slot: "shared"}) }
    Avo::Resources::Project.form_slot(:before_title) { tag.span("Shared second", data: {test_slot: "shared-2"}) }
    Avo::Resources::Project.form_slot(:before_form) { tag.p("Outside: #{form.nil?}", id: "before-form") }
    Avo::Resources::Project.form_slot(:after_form) { tag.p("Outside: #{form.nil?}", id: "after-form") }
    Avo::Resources::Project.form_slot(:after_body) do
      tag.p("#{view}: #{record.new_record?}: #{form.object == record}", id: "form-context")
    end
    %i[before_cards after_cards before_form before_body before_header before_controls
      after_controls after_header after_body after_form].each do |position|
      Avo::Resources::Project.form_slot(position) { tag.span(position, data: {boundary: position}) }
    end

    {"new" => "new", "#{project.to_param}/edit" => "edit"}.each do |path, view|
      get "/admin/resources/projects/#{path}"

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML(response.body)
      expect(document.css("[data-test-slot]").map { |node| node["data-test-slot"] }).to eq(["shared", "shared-2", view])
      expect(document.css("[data-boundary]").map { |node| node["data-boundary"] }).to eq(%w[
        before_cards after_cards before_form before_body before_header before_controls
        after_controls after_header after_body after_form
      ])
      expect(document.at_css("form #form-context").text).to eq("#{view}: #{view == "new"}: true")
      expect(document.css("form[data-controller~='avo-reactive-fields']").size).to eq(1)
      %w[before-form after-form].each do |id|
        expect(document.at_css("##{id}").text).to eq("Outside: true")
        expect(document.at_css("##{id}").ancestors("form")).to be_empty
      end
    end
  end

  it "wraps built-in content lazily and chooses a specific replacement over a shared fallback" do
    Avo::Resources::Project.edit_slot(:title, replace: true) { tag.em(default_content.call, id: "edit-title") }
    Avo::Resources::Project.form_slot(:title, replace: true) { tag.em("Shared title", id: "shared-title") }
    Avo::Resources::Project.form_slot(:form, replace: true) { tag.section(default_content.call, id: "wrapped-form") }
    Avo::Resources::Project.form_slot(:body, replace: true) { tag.div(default_content.call, id: "wrapped-body") }
    Avo::Resources::Project.form_slot(:before_body) { tag.p("Outside body", id: "body-start") }

    get "/admin/resources/projects/#{project.to_param}/edit"

    document = Nokogiri::HTML(response.body)
    expect(document.at_css("form #wrapped-form #wrapped-body #edit-title").text).to eq("Review launch")
    expect(document.at_css("form #body-start")).to be_present
    expect(document.at_css("#wrapped-body #body-start")).to be_nil
    expect(document.at_css("input[name='project[name]']")["value"]).to eq("Review launch")
    expect(document.at_css("form[data-controller~='avo-reactive-fields'] input[name='_method']")["value"]).to eq("put")
    expect(document.at_css("#shared-title")).to be_nil

    get "/admin/resources/projects/new"

    expect(Nokogiri::HTML(response.body).at_css("form #wrapped-form #wrapped-body #shared-title").text).to eq("Shared title")
  end

  it "lets a replacement skip nested defaults, while retaining surrounding additions and form transport" do
    Avo::Resources::Project.form_slot(:before_form) { tag.p("Before", id: "outer-before") }
    Avo::Resources::Project.form_slot(:after_form) { tag.p("After", id: "outer-after") }
    Avo::Resources::Project.form_slot(:body, replace: true) { raise "An unused default must stay lazy" }
    Avo::Resources::Project.form_slot(:form, replace: true) do
      safe_join([form.text_field(:name, value: "Slot-created project"), form.hidden_field(:users_required, value: 12), form.submit("Create from slot")])
    end

    get "/admin/resources/projects/new", params: {via_belongs_to_target_name: "comment_commentable_id"}

    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    expect(document.css("form[data-controller~='avo-reactive-fields']").size).to eq(1)
    expect(document.at_css("form[data-controller~='avo-reactive-fields']")["action"]).to end_with("/admin/resources/projects")
    expect(document.at_css("form input[name='via_belongs_to_target_name']")["value"]).to eq("comment_commentable_id")
    expect(document.at_css("form input[name='project[name]']")["value"]).to eq("Slot-created project")
    expect(document.at_css("#outer-before")).to be_present
    expect(document.at_css("#outer-after")).to be_present

    post "/admin/resources/projects", params: {project: {name: "Slot-created project", users_required: 12}}

    expect(response).to have_http_status(:redirect)
    expect(::Project.find_by!(name: "Slot-created project").users_required).to eq(12)
  end

  it "uses New and Edit slots again after failed creates and updates, with the submitted record and errors" do
    Avo::Resources::Project.new_slot(:before_body) { tag.p("New errors: #{record.errors[:name].join}", id: "new-errors") }
    Avo::Resources::Project.edit_slot(:before_body) { tag.p("Edit errors: #{record.errors[:name].join}", id: "edit-errors") }
    Avo::Resources::Project.form_slot(:after_body) { tag.p("#{view}: #{form.object.name.inspect}", id: "submitted") }

    post "/admin/resources/projects", params: {project: {name: "", users_required: 12}}

    expect(response).to have_http_status(422)
    document = Nokogiri::HTML(response.body)
    expect(document.at_css("form #new-errors").text).to include("can't be blank")
    expect(document.at_css("#edit-errors")).to be_nil
    expect(document.at_css("form #submitted").text).to eq('new: ""')

    put "/admin/resources/projects/#{project.to_param}", params: {project: {name: ""}}

    expect(response).to have_http_status(422)
    document = Nokogiri::HTML(response.body)
    expect(document.at_css("form #edit-errors").text).to include("can't be blank")
    expect(document.at_css("#new-errors")).to be_nil
    expect(document.at_css("form #submitted").text).to eq('edit: ""')
    expect(project.reload.name).to eq("Review launch")
  end

  it "customizes belongs-to modal title, body and controls without removing its accessible chrome" do
    Avo::Resources::Project.new_slot(:before_title) { tag.span("Before modal", id: "modal-before-title") }
    Avo::Resources::Project.form_slot(:title, replace: true) { tag.span(default_content.call, id: "modal-title-default") }
    Avo::Resources::Project.form_slot(:after_title) { tag.span("After modal", id: "modal-after-title") }
    Avo::Resources::Project.form_slot(:header, replace: true) { raise "Modal chrome is protected" }
    Avo::Resources::Project.form_slot(:after_body) { tag.p("Form: #{form.object.new_record?}", id: "modal-body") }
    Avo::Resources::Project.form_slot(:controls, replace: true) { tag.div(default_content.call, id: "modal-controls") }

    get "/admin/resources/projects/new",
      params: {modal_layout: true, via_belongs_to_resource_class: "Avo::Resources::Comment", via_relation: "commentable"},
      headers: {"Turbo-Frame" => "modal_frame_nested"}

    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    dialog = document.at_css("form [role='dialog']")
    heading = document.at_css("##{dialog["aria-labelledby"]}")
    expect(heading.css("span").map(&:text)).to eq(["Before modal", "Create new project", "After modal"])
    expect(dialog.at_css("button[data-action='click->modal#closeModal']")).to be_present
    expect(dialog.at_css("#modal-body").text).to eq("Form: true")
    expect(dialog.at_css(".modal__controls #modal-controls button[type='submit']")).to be_present
  end

  it "rejects regions belonging to another view and duplicate replacements through either API" do
    expect { Avo::Resources::Project.show_slot(:before_form) {} }.to raise_error(ArgumentError, /Unknown show slot/)
    expect { Avo::Resources::Project.form_slot(:before_records) {} }.to raise_error(ArgumentError, /Unknown form slot/)
    Avo::Resources::Project.edit_slot(:body, replace: true) {}
    expect { Avo::Resources::Project.view_slot(:edit, :body, replace: true) {} }
      .to raise_error(ArgumentError, /already has a replacement/)
  end

  it "inherits shared slots while a child's specific replacement keeps Avo's default, not the parent's replacement" do
    parent = Class.new(Avo::BaseResource)
    stub_const("FormSlotParentResource", parent)
    parent.abstract_resource!
    parent.model_class = ::Project
    def parent.class_name = "Project"

    parent.form_slot(:before_title) { tag.span("Inherited addition", class: "inherited") }
    parent.form_slot(:title, replace: true) { tag.span("Parent replacement", class: "parent-title") }
    child = Class.new(parent)
    sibling = Class.new(parent)
    stub_const("FormSlotChildResource", child)
    stub_const("FormSlotSiblingResource", sibling)
    [child, sibling].each(&:abstract_resource!)
    child.new_slot(:title, replace: true) { tag.span(default_content.call, class: "child-title") }
    child.form_slot(:before_title) { tag.span("Child addition", class: "child-addition") }

    [parent, child, sibling].each do |resource_class|
      resource = resource_class.new(record: ::Project.new, view: Avo::ViewInquirer.new(:new))
      document = Nokogiri::HTML(Avo::BaseController.render(
        Avo::Views::ResourceEditComponent.new(resource: resource, view: Avo::ViewInquirer.new(:new)), layout: false
      ))

      expect(document.css(".inherited").size).to eq(1)
      if resource_class == child
        expect(document.at_css(".child-title").text).to eq("Create new project")
        expect(document.at_css(".parent-title")).to be_nil
        expect(document.at_css(".child-addition")).to be_present
      else
        expect(document.at_css(".parent-title").text).to eq("Parent replacement")
        expect(document.at_css(".child-addition")).to be_nil
      end
    end
  end

  it "wraps both sets of form controls when footer buttons are enabled" do
    footers = Avo.configuration.buttons_on_form_footers
    Avo.configuration.buttons_on_form_footers = true
    Avo::Resources::Project.form_slot(:controls, replace: true) do
      tag.div(default_content.call, class: "wrapped-controls")
    end

    get "/admin/resources/projects/#{project.to_param}/edit"

    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    expect(document.css("form .wrapped-controls button[type='submit']").size).to eq(2)
  ensure
    Avo.configuration.buttons_on_form_footers = footers
  end
end
