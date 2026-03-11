require "spec_helper"
require "open3"
require "pathname"
require "rbconfig"

RSpec.describe "require avo smoke test" do
  it "loads avo with bundler setup and exits successfully" do
    root = Pathname.new(__dir__).join("..", "..", "..").expand_path
    script = <<~RUBY
      require "bundler/setup"
      require "avo"
      puts "OK"
    RUBY

    stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-e", script, chdir: root.to_s)

    expect(status.success?).to eq(true), "stdout: #{stdout}\nstderr: #{stderr}"
    expect(stdout).to include("OK")
  end
end
