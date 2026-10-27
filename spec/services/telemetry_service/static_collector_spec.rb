require "rails_helper"
require "fileutils"
require "tmpdir"
require "open3"

RSpec.describe Avo::Services::TelemetryService::StaticCollector do
  # Builds a throwaway app root so the assertions stay deterministic and
  # independent of the dummy app's (evolving) resources.
  around do |example|
    Dir.mktmpdir("avo-telemetry") do |dir|
      @app_root = dir
      write_fixture
      example.run
    end
  end

  subject(:metadata) { described_class.new(@app_root).collect }

  # Paths are relative to app/avo, where all the Avo entities live.
  def write(relative_path, contents)
    write_app_file(File.join("app", "avo", relative_path), contents)
  end

  def write_app_file(relative_path, contents)
    path = File.join(@app_root, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, contents)
  end

  def write_fixture
    write "resources/post.rb", <<~RUBY
      class Avo::Resources::Post < Avo::BaseResource
        def fields
          field :id, as: :id
          field :name, as: :text
          field :body, as: :textarea
          field :color, as: :color_picker
          action Avo::Actions::Publish
          filter Avo::Filters::ByStatus
        end
      end
    RUBY

    write "resources/comment.rb", <<~RUBY
      class Avo::Resources::Comment < Avo::BaseResource
        def fields
          field :id, as: :id
          field :body, as: :text
          action Avo::Actions::Publish
        end
      end
    RUBY

    write "actions/publish.rb", "class Avo::Actions::Publish < Avo::BaseAction; end"
    write "filters/by_status.rb", "class Avo::Filters::ByStatus < Avo::Filters::SelectFilter; end"
    write "fields/color_picker_field.rb", "class Avo::Fields::ColorPickerField < Avo::Fields::BaseField; end"

    # Not a resource — must be ignored despite containing a `field` call and
    # a "Resource"-ish constant name.
    write "resource_tools/foo.rb", <<~RUBY
      class Avo::ResourceTools::Foo < Avo::ResourceTools::Tool
        def fields
          field :ignored, as: :text
        end
      end
    RUBY
  end

  it "counts resources by directory, not mistaking resource tools for resources" do
    expect(metadata[:resources_count]).to eq(2)
    # The fixture's resource_tools/foo.rb is a tool, never a resource.
    expect(metadata[:tools_count]).to eq(1)
  end

  it "counts fields across resources and averages per resource" do
    expect(metadata[:fields_count]).to eq(6)
    expect(metadata[:fields_per_resource]).to eq("3.0")
  end

  it "breaks down field types with string keys, hiding app-defined type names" do
    # color_picker is defined under app/avo/fields, so its name stays in the app.
    expect(metadata[:field_types]).to eq(
      "id" => 2,
      "text" => 2,
      "textarea" => 1,
      "custom_1" => 1
    )
  end

  it "counts only app-defined custom field usages" do
    # color_picker is defined under app/avo/fields and used once.
    expect(metadata[:custom_fields_count]).to eq(1)
  end

  it "counts distinct wired actions and averages total wirings" do
    # Publish is wired on both resources -> distinct 1, total 2 over 2 resources.
    expect(metadata[:actions_count]).to eq(1)
    expect(metadata[:actions_per_resource]).to eq("1.0")
  end

  it "counts distinct wired filters and averages total wirings" do
    expect(metadata[:filters_count]).to eq(1)
    expect(metadata[:filters_per_resource]).to eq("0.5")
  end

  it "reports zero dashboards when none are defined" do
    expect(metadata[:dashboards_count]).to eq(0)
  end

  context "with a dynamic field type" do
    before do
      write "resources/dynamic.rb", <<~RUBY
        class Avo::Resources::Dynamic < Avo::BaseResource
          def fields
            field :thing, as: field_type
          end
        end
      RUBY
    end

    it "counts the field but not an (unknowable) type" do
      expect(metadata[:resources_count]).to eq(3)
      expect(metadata[:fields_count]).to eq(7)
      # No new entry added to field_types for the dynamic `as:`.
      expect(metadata[:field_types].values.sum).to eq(6)
    end
  end

  context "with boards, tools, forms and pages" do
    before do
      write "resources/board.rb", <<~RUBY
        class Avo::Resources::Board < Avo::BaseResource
          self.model_class = "Avo::Kanban::Board"
        end
      RUBY
      write "resource_tools/dashboard_tool.rb", "class Avo::ResourceTools::DashboardTool < Avo::BaseResourceTool; end"
      write "forms/contact.rb", <<~RUBY
        class Avo::Forms::Contact < Avo::Forms::Core::Form
          def fields
            field :name, as: :text
            field :email, as: :text
          end
        end
      RUBY
      write "pages/settings.rb", "class Avo::Pages::Settings < Avo::Forms::Core::Page; end"
    end

    it "counts boards, tools, forms (with their fields) and pages" do
      expect(metadata[:boards_count]).to eq(1)
      # The base fixture's resource_tools/foo.rb + this dashboard_tool = 2.
      expect(metadata[:tools_count]).to eq(2)
      expect(metadata[:forms_count]).to eq(1)
      expect(metadata[:form_fields_count]).to eq(2)
      expect(metadata[:pages_count]).to eq(1)
    end

    it "does not count boards as extra resources nor tools/forms as resources" do
      # base fixture (post, comment) + board resource = 3; tools/forms/pages excluded.
      expect(metadata[:resources_count]).to eq(3)
    end

    it "does not let form fields leak into resource field counts" do
      # 6 from base resources; the form's 2 fields are tallied separately.
      expect(metadata[:fields_count]).to eq(6)
    end
  end

  context "with a resource using the kanban_view DSL" do
    before do
      write "resources/task.rb", <<~RUBY
        class Avo::Resources::Task < Avo::BaseResource
          self.kanban_view = {column: :status, item: {title: :name}}
        end
      RUBY
    end

    it "detects the board via kanban_view" do
      expect(metadata[:boards_count]).to eq(1)
    end
  end

  context "with a field that omits `as:`" do
    before do
      write "resources/plain.rb", <<~RUBY
        class Avo::Resources::Plain < Avo::BaseResource
          def fields
            field :name
            field :title,
              readonly: true
          end
        end
      RUBY
    end

    it "types them as text, the way FieldParser defaults them" do
      expect(metadata[:field_types]["text"]).to eq(4)
      expect(metadata[:fields_count]).to eq(8)
    end
  end

  context "with `as:` pointing at a field class" do
    before do
      write "resources/person.rb", <<~RUBY
        class Avo::Resources::Person < Avo::BaseResource
          def fields
            field :kind, as: ::Pluggy::Fields::RadioField
            field :note, as: Avo::Fields::TextareaField
          end
        end
      RUBY
    end

    it "derives the type from the class name, as the runtime does" do
      expect(metadata[:field_types]["textarea"]).to eq(2)
    end

    it "reports a class outside Avo's namespace under an anonymous key" do
      # color_picker (app/avo/fields) and the Pluggy radio class are both custom.
      expect(metadata[:field_types]).not_to include("radio", "color_picker")
      expect(metadata[:field_types].slice("custom_1", "custom_2")).to eq("custom_1" => 1, "custom_2" => 1)
    end

    it "counts a class outside Avo's namespace as custom" do
      # The base fixture's color_picker (1) + the Pluggy radio field (1).
      # Avo::Fields::TextareaField is core, so it does not count.
      expect(metadata[:custom_fields_count]).to eq(2)
    end
  end

  context "with a bare `field` reference that is not a declaration" do
    before do
      write "resources/interpolated.rb", <<~'RUBY'
        class Avo::Resources::Interpolated < Avo::BaseResource
          def fields
            field :level, as: :select, options: {"#{field.id}": "field", "#{record.id}": "record"}
          end
        end
      RUBY
    end

    it "counts only the declaration" do
      expect(metadata[:fields_count]).to eq(7)
      expect(metadata[:field_types]["select"]).to eq(1)
    end
  end

  context "with fields and actions declared in a shared concern" do
    before do
      write "concerns/timestamps.rb", <<~RUBY
        module Avo::Concerns::Timestamps
          def fields
            field :created_at, as: :date_time
            field :updated_at, as: :date_time
            action Avo::Actions::Touch
          end
        end
      RUBY

      write "resources/article.rb", <<~RUBY
        class Avo::Resources::Article < Avo::BaseResource
          include Avo::Concerns::Timestamps

          def fields
            field :title, as: :text
          end
        end
      RUBY

      write "resources/note.rb", <<~RUBY
        class Avo::Resources::Note < Avo::BaseResource
          include Timestamps
        end
      RUBY
    end

    it "credits the concern's fields to every resource that includes it" do
      # base 6 + article (1 own + 2 concern) + note (2 concern) = 11.
      expect(metadata[:fields_count]).to eq(11)
      expect(metadata[:field_types]["date_time"]).to eq(4)
    end

    it "credits the concern's actions too" do
      # Publish (base fixture) + Touch, wired via the concern on two resources.
      expect(metadata[:actions_count]).to eq(2)
    end

    it "does not count the concern itself as a resource" do
      expect(metadata[:resources_count]).to eq(4)
    end
  end

  context "with a concern that includes another concern" do
    before do
      write "concerns/auditable.rb", <<~RUBY
        module Avo::Concerns::Auditable
          include Avo::Concerns::Stamped

          def fields
            field :audited_by, as: :text
          end
        end
      RUBY

      write "concerns/stamped.rb", <<~RUBY
        module Avo::Concerns::Stamped
          def fields
            field :stamped_at, as: :date_time
          end
        end
      RUBY

      write "resources/invoice.rb", <<~RUBY
        class Avo::Resources::Invoice < Avo::BaseResource
          include Avo::Concerns::Auditable
        end
      RUBY

      write "resources/receipt.rb", <<~RUBY
        class Avo::Resources::Receipt < Avo::BaseResource
          include Avo::Concerns::Auditable
        end
      RUBY
    end

    it "resolves the nested concern once per resource, not once per visit" do
      # Each of the two resources gets audited_by + stamped_at.
      expect(metadata[:field_types]["text"]).to eq(4)
      expect(metadata[:field_types]["date_time"]).to eq(2)
      expect(metadata[:fields_count]).to eq(10)
    end
  end

  context "with resources registered through config.resources" do
    before do
      write_app_file "config/initializers/avo.rb", <<~RUBY
        Avo.configure do |config|
          config.resources = [
            Avo::Resources::Legacy,
            "Avo::Resources::Post",
            Avo::Resources::FromAGem
          ]
        end
      RUBY

      write_app_file "app/admin/legacy.rb", <<~RUBY
        class Avo::Resources::Legacy < Avo::BaseResource
          def fields
            field :id, as: :id
            field :label, as: :text
          end
        end
      RUBY
    end

    it "picks up a resource living outside app/avo" do
      expect(metadata[:resources_count]).to eq(3)
      expect(metadata[:fields_count]).to eq(8)
    end

    it "does not double-count one already found under app/avo" do
      # Post is listed in the initializer and lives in app/avo/resources.
      expect(metadata[:field_types]["textarea"]).to eq(1)
    end
  end

  context "with a concern and a field declared inside nested modules" do
    before do
      write "concerns/stamps.rb", <<~RUBY
        module Avo
          module Concerns
            module Stamps
              def fields
                field :created_at, as: :date_time
              end
            end
          end
        end
      RUBY

      write "fields/stars_field.rb", <<~RUBY
        module Avo
          module Fields
            class StarsField < BaseField; end
          end
        end
      RUBY

      write "resources/review.rb", <<~RUBY
        class Avo::Resources::Review < Avo::BaseResource
          include Avo::Concerns::Stamps

          def fields
            field :rating, as: :stars
          end
        end
      RUBY
    end

    it "resolves them by their full name, not the outer module" do
      expect(metadata[:field_types]["date_time"]).to eq(1)
      # color_picker from the base fixture, plus stars.
      expect(metadata[:custom_fields_count]).to eq(2)
    end
  end

  context "with a configured resource that shares its name with a model" do
    before do
      write_app_file "config/initializers/avo.rb", <<~RUBY
        Avo.configure { |config| config.resources = [Avo::Resources::Widget] }
      RUBY

      # Globbed before app/resources/widget.rb.
      write_app_file "app/models/widget.rb", "class Widget < ApplicationRecord; end"

      write_app_file "app/resources/widget.rb", <<~RUBY
        class Avo::Resources::Widget < Avo::BaseResource
          include Avo::Concerns::Stamps

          def fields
            field :name, as: :text
          end
        end
      RUBY

      write "concerns/stamps.rb", <<~RUBY
        module Avo::Concerns::Stamps
          def fields
            field :created_at, as: :date_time
          end
        end
      RUBY
    end

    it "counts the resource, with its concern, and not the model" do
      expect(metadata[:resources_count]).to eq(3)
      expect(metadata[:fields_count]).to eq(8)
      expect(metadata[:field_types]["date_time"]).to eq(1)
    end
  end

  context "on a Ruby without Prism" do
    it "loads, and collects nothing" do
      script = <<~RUBY
        module Kernel
          alias_method :original_require, :require
          def require(name) = (name == "prism") ? raise(LoadError) : original_require(name)
        end
        load ARGV.fetch(0)
        print Avo::Services::TelemetryService::StaticCollector.new(Dir.pwd).collect.inspect
      RUBY
      source = Avo::Engine.root.join("lib/avo/services/telemetry_service/static_collector.rb").to_s

      output, status = Open3.capture2e(RbConfig.ruby, "-e", script, source)

      expect(status).to be_success, output
      expect(output).to eq("{}")
    end
  end

  context "when one file trips up the visitor" do
    it "drops that file and still counts the rest" do
      calls = 0
      allow_any_instance_of(described_class::FileVisitor).to receive(:to_result).and_wrap_original do |original, *args|
        calls += 1
        raise NoMethodError, "unexpected node" if args.last.to_s.end_with?("comment.rb")
        original.call(*args)
      end

      expect(metadata[:resources_count]).to eq(1)
      expect(calls).to be > 1
    end
  end

  context "when app/avo does not exist" do
    subject(:metadata) { described_class.new(File.join(@app_root, "nope")).collect }

    it "returns empty counts without raising" do
      expect(metadata[:resources_count]).to eq(0)
      expect(metadata[:fields_count]).to eq(0)
      expect(metadata[:fields_per_resource]).to eq("0.0")
      expect(metadata[:field_types]).to eq({})
    end
  end
end
