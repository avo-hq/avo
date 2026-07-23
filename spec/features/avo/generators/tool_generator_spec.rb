require "rails_helper"
require "rails/generators"

RSpec.feature "tool generator", type: :feature, acquire_lock: :generator do
  let(:routes_path) { Rails.root.join("config/routes.rb") }
  let(:generated_files) do
    [
      Rails.root.join("app/views/avo/sidebar/items/_lolo.html.erb").to_s,
      Rails.root.join("app/views/avo/tools/lolo.html.erb").to_s
    ]
  end

  around do |example|
    original_routes = File.read(routes_path)

    example.run
  ensure
    File.write(routes_path, original_routes)
    delete_files(generated_files)

    controller_path = Rails.root.join("app/controllers/avo/tools_controller.rb")
    if File.exist?(controller_path)
      content = File.read(controller_path)
      cleaned = content.gsub(/\n  def lolo\n.*?  end\n/m, "\n")
      File.write(controller_path, cleaned)
    end
  end

  before do
    allow(Rails::Command).to receive(:invoke).with("restart")
  end

  def invoke_tool_generator
    Rails::Generators.invoke("avo:tool", ["lolo", "-q"], {destination_root: Rails.root})
  end

  it "converts a one-line mount_avo with an inline comment into a block without commenting out do/end" do
    File.write(routes_path, <<~RUBY)
      Rails.application.routes.draw do
        mount_avo mount_lookbook: true # admin panel
      end
    RUBY

    invoke_tool_generator

    routes = File.read(routes_path)

    # <<~ strips common indent; re-indent so we assert the 2-space routes nesting.
    expect(routes).to include(<<~RUBY.indent(2))
      mount_avo mount_lookbook: true do # admin panel
        get "lolo", to: "tools#lolo", as: :lolo
      end
    RUBY
    expect(routes).not_to match(/# admin panel do/)
  end

  it "converts a one-line mount_avo without a comment into a block" do
    File.write(routes_path, <<~RUBY)
      Rails.application.routes.draw do
        mount_avo
      end
    RUBY

    invoke_tool_generator

    expect(File.read(routes_path)).to include(<<~RUBY.indent(2))
      mount_avo do
        get "lolo", to: "tools#lolo", as: :lolo
      end
    RUBY
  end

  it "does not treat a comment that contains do as an existing mount_avo block" do
    File.write(routes_path, <<~RUBY)
      Rails.application.routes.draw do
        mount_avo # do not enable lookbook
      end
    RUBY

    invoke_tool_generator

    routes = File.read(routes_path)

    expect(routes).to include(<<~RUBY.indent(2))
      mount_avo do # do not enable lookbook
        get "lolo", to: "tools#lolo", as: :lolo
      end
    RUBY
  end

  it "converts a one-line mount_avo with mount_lookbook into a block" do
    File.write(routes_path, <<~RUBY)
      Rails.application.routes.draw do
        mount_avo mount_lookbook: true
      end
    RUBY

    invoke_tool_generator

    expect(File.read(routes_path)).to include(<<~RUBY.indent(2))
      mount_avo mount_lookbook: true do
        get "lolo", to: "tools#lolo", as: :lolo
      end
    RUBY
  end

  it "injects the route into an existing mount_avo block, keeping a comment after do" do
    File.write(routes_path, <<~RUBY)
      Rails.application.routes.draw do
        mount_avo mount_lookbook: true do # admin panel
        end
      end
    RUBY

    invoke_tool_generator

    routes = File.read(routes_path)

    expect(routes).to include(<<~RUBY.indent(2))
      mount_avo mount_lookbook: true do # admin panel
        get "lolo", to: "tools#lolo", as: :lolo
      end
    RUBY
    # The `do` line is left untouched — no second `do` appended to it.
    expect(routes).not_to match(/# admin panel do/)
  end
end
