require "spec_helper"
require "open3"
require "pathname"

RSpec.describe "require avo smoke test", type: :feature do
  it "loads avo with bundler setup and exits successfully" do
    root = Pathname.new(__dir__).join("..", "..", "..").expand_path
    command = %(bundle exec ruby -e 'require "bundler/setup"; require "avo"; puts "OK"')

    stdout, stderr, status = Open3.capture3(command, chdir: root.to_s)

    expect(status.success?).to eq(true), "stdout: #{stdout}\nstderr: #{stderr}"
    expect(stdout).to include("OK")
  end
end
