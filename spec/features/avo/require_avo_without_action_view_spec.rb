require "spec_helper"
require "open3"
require "rbconfig"

RSpec.describe "requiring avo" do
  it "loads without ActionView being preloaded" do
    script = <<~RUBY
      if defined?(ActionView)
        warn "ActionView should not be defined before requiring avo"
        exit 1
      end

      require "avo"
      puts "loaded"
    RUBY

    root = File.expand_path("../../..", __dir__)
    lib_path = File.join(root, "lib")

    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      "-I#{lib_path}",
      "-e",
      script,
      chdir: root
    )

    expect(status).to be_success, <<~MESSAGE
      expected `require "avo"` to succeed without ActionView preloaded
      stdout:
      #{stdout}
      stderr:
      #{stderr}
    MESSAGE
    expect(stdout).to include("loaded")
  end
end
