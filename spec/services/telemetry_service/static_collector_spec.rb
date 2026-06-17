require "rails_helper"
require "fileutils"
require "tmpdir"

RSpec.describe Avo::Services::TelemetryService::StaticCollector do
  # Builds a throwaway app/avo tree so the assertions stay deterministic and
  # independent of the dummy app's (evolving) resources.
  around do |example|
    Dir.mktmpdir("avo-telemetry") do |dir|
      @avo_root = dir
      write_fixture
      example.run
    end
  end

  subject(:metadata) { described_class.new(@avo_root).collect }

  def write(relative_path, contents)
    path = File.join(@avo_root, relative_path)
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

  it "breaks down field types with string keys, sorted by count" do
    expect(metadata[:field_types]).to eq(
      "id" => 2,
      "text" => 2,
      "textarea" => 1,
      "color_picker" => 1
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

  context "when app/avo does not exist" do
    subject(:metadata) { described_class.new(File.join(@avo_root, "nope")).collect }

    it "returns empty counts without raising" do
      expect(metadata[:resources_count]).to eq(0)
      expect(metadata[:fields_count]).to eq(0)
      expect(metadata[:fields_per_resource]).to eq("0.0")
      expect(metadata[:field_types]).to eq({})
    end
  end
end
