require "bundler"
require "open3"
require "rake"
require "tmpdir"

RSpec.describe "avo:update" do
  def git(*)
    output, error, status = Open3.capture3("git", *)
    raise error unless status.success?
    output.strip
  end

  around do |example|
    original_application = Rake.application
    original_push = ENV["AVO_UPDATE_PUSH"]
    Rake.application = Rake::Application.new
    Rake::Task.define_task(:environment)
    load File.expand_path("../../lib/tasks/avo_tasks.rake", __dir__)

    Dir.mktmpdir("avo-update") do |directory|
      @remote = File.join(directory, "remote.git")
      @repository = File.join(directory, "app")
      FileUtils.mkdir_p(@repository)
      Dir.chdir(@repository) do
        git("init", "--bare", @remote)
        git("--git-dir", @remote, "config", "core.hooksPath", File.join(@remote, "hooks"))
        git("init", "-b", "main")
        git("config", "user.name", "Test User")
        git("config", "user.email", "test@example.com")
        git("config", "commit.gpgsign", "false")
        git("config", "core.hooksPath", File.join(@repository, ".git/hooks"))
        File.write("Gemfile.lock", "original lockfile\n")
        File.write("other.txt", "original\n")
        git("add", ".")
        git("commit", "-m", "Initial commit")
        git("remote", "add", "origin", @remote)
        git("push", "-u", "origin", "main")
        @initial_head = git("rev-parse", "HEAD")
        example.run
      end
    end
  ensure
    Rake.application = original_application
    ENV["AVO_UPDATE_PUSH"] = original_push
  end

  before do
    ENV["AVO_UPDATE_PUSH"] = "1"
    stub_const("Avo", double(plugin_manager: double(plugins: [])))
    allow(Bundler).to receive(:default_lockfile).and_return(Pathname.new(File.join(@repository, "Gemfile.lock")))
    allow(Bundler).to receive(:with_original_env) do
      File.write("Gemfile.lock", "updated lockfile\n")
      true
    end
  end

  def update
    Rake::Task["avo:update"].invoke
  end

  def remote_head
    git("--git-dir", @remote, "rev-parse", "refs/heads/main")
  end

  it "commits only the lockfile and pushes to the existing upstream" do
    allow(Bundler).to receive(:with_original_env) do
      File.write("Gemfile.lock", "updated lockfile\n")
      File.write("other.txt", "unrelated change\n")
      git("add", "other.txt")
      true
    end

    update

    expect(git("log", "-1", "--format=%s")).to eq("Update Avo gems")
    expect(git("diff-tree", "--no-commit-id", "--name-only", "-r", "HEAD")).to eq("Gemfile.lock")
    expect(git("show", "HEAD:Gemfile.lock")).to eq("updated lockfile")
    expect(remote_head).to eq(git("rev-parse", "HEAD"))
    expect(git("diff", "--cached", "--name-only")).to eq("other.txt")
  end

  [nil, "0"].each do |value|
    it "updates without committing or pushing when AVO_UPDATE_PUSH is #{value.inspect}" do
      ENV["AVO_UPDATE_PUSH"] = value
      git("branch", "--unset-upstream")
      File.write("other.txt", "existing work\n")

      update

      expect(File.read("Gemfile.lock")).to eq("updated lockfile\n")
      expect(git("rev-parse", "HEAD")).to eq(@initial_head)
      expect(remote_head).to eq(@initial_head)
    end
  end

  ["unstaged", "staged"].each do |state|
    it "rejects #{state} changes before updating" do
      File.write("other.txt", "existing work\n")
      git("add", "other.txt") if state == "staged"

      expect { update }.to raise_error(SystemExit, /no changes to tracked files/)
      expect(File.read("Gemfile.lock")).to eq("original lockfile\n")
      expect(remote_head).to eq(@initial_head)
    end
  end

  [true, false].each do |tracked_lockfile|
    it "allows untracked files with a #{tracked_lockfile ? "tracked" : "untracked"} lockfile" do
      unless tracked_lockfile
        git("rm", "--cached", "Gemfile.lock")
        git("commit", "-m", "Untrack lockfile")
        git("push")
      end
      File.write("new.txt", "untracked work\n")

      expect { update }.not_to raise_error

      expect(git("diff-tree", "--no-commit-id", "--name-only", "-r", "HEAD")).to eq("Gemfile.lock")
      expect(git("show", "HEAD:Gemfile.lock")).to eq("updated lockfile")
      expect(remote_head).to eq(git("rev-parse", "HEAD"))
      expect(File.read("new.txt")).to eq("untracked work\n")
      expect(git("status", "--porcelain")).to eq("?? new.txt")
    end
  end

  it "rejects a branch without an upstream before updating" do
    git("branch", "--unset-upstream")

    expect { update }.to raise_error(SystemExit, /existing upstream/)
    expect(File.read("Gemfile.lock")).to eq("original lockfile\n")
  end

  it "rejects a detached HEAD before updating" do
    git("checkout", "--detach")

    expect { update }.to raise_error(SystemExit, /existing upstream/)
    expect(File.read("Gemfile.lock")).to eq("original lockfile\n")
  end

  it "rejects a directory outside Git before updating" do
    Dir.mktmpdir("avo-update-no-git") do |directory|
      Dir.chdir(directory) do
        expect { update }.to raise_error(SystemExit, /requires a Git repository/)
      end
    end
    expect(File.read("Gemfile.lock")).to eq("original lockfile\n")
  end

  it "does not commit or push after a failed update" do
    allow(Bundler).to receive(:with_original_env) do
      File.write("Gemfile.lock", "partial update\n")
      false
    end

    expect { update }.to raise_error(SystemExit, /Gem update failed/)
    expect(git("rev-parse", "HEAD")).to eq(@initial_head)
    expect(git("diff", "--cached", "--name-only")).to be_empty
    expect(remote_head).to eq(@initial_head)
  end

  it "skips committing and pushing when the lockfile is unchanged" do
    allow(Bundler).to receive(:with_original_env).and_return(true)
    git("commit", "--allow-empty", "-m", "Unpushed work")
    local_head = git("rev-parse", "HEAD")

    expect { update }.not_to raise_error
    expect(git("rev-parse", "HEAD")).to eq(local_head)
    expect(remote_head).to eq(@initial_head)
  end

  it "does not push if committing fails" do
    File.write(".git/hooks/pre-commit", "#!/bin/sh\nexit 1\n", mode: "w", perm: 0o755)

    expect { update }.to raise_error(SystemExit, /Commit failed/)
    expect(git("rev-parse", "HEAD")).to eq(@initial_head)
    expect(remote_head).to eq(@initial_head)
  end

  it "keeps the local commit and reports a rejected push" do
    File.write(File.join(@remote, "hooks/pre-receive"), "#!/bin/sh\nexit 1\n", mode: "w", perm: 0o755)

    expect { update }.to raise_error(SystemExit, /Push failed/)
    expect(git("rev-parse", "HEAD")).not_to eq(@initial_head)
    expect(git("show", "HEAD:Gemfile.lock")).to eq("updated lockfile")
    expect(remote_head).to eq(@initial_head)
  end
end
