require "spec_helper"
require "open3"
require "rbconfig"

RSpec.describe "requiring avo/asset_manager" do
  it "loads without ActionView being preloaded" do
    script = <<~RUBY
      require "bundler/setup"
      if defined?(ActionView)
        warn "ActionView should not be defined before requiring avo"
        exit 1
      end

      require "avo/asset_manager"
      puts "loaded"
    RUBY

    root = File.expand_path("../../..", __dir__)
    lib_path = File.join(root, "lib")

    stdout, stderr, status = Open3.capture3(
      {"BUNDLE_GEMFILE" => ENV.fetch("BUNDLE_GEMFILE", File.join(root, "Gemfile"))},
      RbConfig.ruby,
      "-I#{lib_path}",
      "-e",
      script,
      chdir: root
    )

    expect(status).to be_success, <<~MESSAGE
      expected `require "avo/asset_manager"` to succeed without ActionView preloaded
      stdout:
      #{stdout}
      stderr:
      #{stderr}
    MESSAGE
    expect(stdout).to include("loaded")
  end
end
