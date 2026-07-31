require "rails_helper"
require "rails/generators"

RSpec.feature "skills generator", type: :feature, acquire_lock: :generator do
  let(:targets) { %w[.claude/skills/avo .agents/skills/avo .cursor/skills/avo] }
  let(:gem_resolver) { Avo::Engine.root.join("lib", "avo", "skills", "bin", "avo-skills-resolve") }

  def generate(args = ["-q", "--skip-avo-version"])
    Rails::Generators.invoke("avo:skills", args, {destination_root: Rails.root})
  end

  def cleanup
    %w[.claude .agents .cursor].each { |dir| FileUtils.rm_rf(Rails.root.join(dir)) }
  end

  after { cleanup }

  it "installs the loader into every scan path" do
    generate

    targets.each do |target|
      expect(File).to exist Rails.root.join(target, "SKILL.md").to_s
      expect(File).to exist Rails.root.join(target, "scripts", "avo-skills-resolve").to_s
    end
  end

  it "installs an executable resolver" do
    generate

    targets.each do |target|
      expect(File).to be_executable Rails.root.join(target, "scripts", "avo-skills-resolve").to_s
    end
  end

  it "copies rather than symlinks, so bundle update cannot break the link" do
    generate

    targets.each do |target|
      expect(File).not_to be_symlink Rails.root.join(target, "SKILL.md").to_s
      expect(File).not_to be_symlink Rails.root.join(target, "scripts", "avo-skills-resolve").to_s
    end
  end

  it "stamps the installed resolver with the gem version but is otherwise identical" do
    generate

    installed = File.read(Rails.root.join(".claude/skills/avo/scripts/avo-skills-resolve"))
    source = File.read(gem_resolver)

    expect(installed).to include(%(STAMP_VERSION="#{Avo::VERSION}"))
    expect(installed.sub(/^STAMP_VERSION=.*$/, "STAMP")).to eq source.sub(/^STAMP_VERSION=.*$/, "STAMP")
  end

  it "refreshes an edited copy when re-run" do
    generate

    resolver = Rails.root.join(".claude/skills/avo/scripts/avo-skills-resolve")
    File.write(resolver, "# stale local edit\n")
    generate(["-q", "--skip-avo-version", "--force"])

    expect(File.read(resolver)).to include("STAMP_VERSION=")
    expect(File.read(resolver)).not_to include("stale local edit")
  end

  it "installs one target only with --only" do
    generate(["-q", "--skip-avo-version", "--only", "claude"])

    expect(File).to exist Rails.root.join(".claude/skills/avo/SKILL.md").to_s
    expect(File).not_to exist Rails.root.join(".agents/skills/avo/SKILL.md").to_s
    expect(File).not_to exist Rails.root.join(".cursor/skills/avo/SKILL.md").to_s
  end

  it "rejects an unknown --only value instead of installing nothing silently" do
    # Thor catches Thor::Error and prints it rather than propagating through
    # `invoke`, so the observable contract is: named message, nothing installed.
    original = $stderr
    $stderr = StringIO.new
    begin
      generate(["-q", "--skip-avo-version", "--only", "nope"])
      output = $stderr.string
    ensure
      $stderr = original
    end

    expect(output).to match(/Unknown --only value/)
    targets.each { |target| expect(File).not_to exist Rails.root.join(target, "SKILL.md").to_s }
  end

  describe "the installed loader" do
    subject(:body) { File.read(Rails.root.join(".claude/skills/avo/SKILL.md")) }

    before { generate }

    it "declares Bash, without which it cannot run the resolver" do
      frontmatter = body.split("---")[1]

      expect(frontmatter).to match(/^allowed-tools:.*\bBash\b/)
      expect(frontmatter).to match(/^name: avo$/)
    end

    it "keeps the description within the skills-spec limit" do
      description = body[/^description: >-\n((?:  .*\n)+)/, 1]

      expect(description).to be_present
      expect(description.length).to be <= 1024
    end

    it "tells the agent to stop on a resolver error rather than fall back on priors" do
      expect(body).to match(/do not fall back on what you already know about Avo/i)
      expect(body).to include("Report and stop.")
    end

    it "names every location a legacy global install can hide in" do
      expect(body).to include(".claude/skills/avo-*")
      expect(body).to include(".agents/skills/avo-*")
      expect(body).to include(".cursor/skills/avo-*")
      expect(body).to include("~/.claude/skills/avo-*")
    end

    it "names each resolver error token so the agent can act on it" do
      %w[not_an_app avo_not_locked gem_not_on_disk version_mismatch malformed_lock skills_not_shipped].each do |token|
        expect(body).to include(token)
      end
    end
  end
end
