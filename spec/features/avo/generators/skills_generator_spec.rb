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

  describe "legacy cleanup" do
    def plant_legacy(*names, root: ".claude/skills")
      names.map do |name|
        dir = Rails.root.join(root, name)
        FileUtils.mkdir_p(dir)
        File.write(dir.join("SKILL.md"), "---\nname: #{name}\n---\n")
        dir
      end
    end

    it "removes a leftover catalog when asked" do
      stale = plant_legacy("avo-fields", "avo-kanban")
      generate(["-q", "--skip-avo-version", "--clean-legacy"])

      stale.each { |dir| expect(Dir).not_to exist dir.to_s }
    end

    it "leaves the loader it just installed alone" do
      plant_legacy("avo-fields")
      generate(["-q", "--skip-avo-version", "--clean-legacy"])

      expect(File).to exist Rails.root.join(".claude/skills/avo/SKILL.md").to_s
    end

    it "keeps leftovers when told not to clean" do
      stale = plant_legacy("avo-fields")
      generate(["-q", "--skip-avo-version", "--no-clean-legacy"])

      stale.each { |dir| expect(Dir).to exist dir.to_s }
    end

    # A `rm -rf` driven by a name glob alone is not something to hand a user.
    it "ignores an avo-prefixed directory that is not a skill" do
      unrelated = Rails.root.join(".claude/skills/avo-notes")
      FileUtils.mkdir_p(unrelated)
      File.write(unrelated.join("README.md"), "not a skill")

      generate(["-q", "--skip-avo-version", "--clean-legacy"])

      expect(Dir).to exist unrelated.to_s
    end

    it "cleans every scan directory, not just Claude's" do
      stale = %w[.claude/skills .agents/skills .cursor/skills].flat_map { plant_legacy("avo-fields", root: _1) }
      generate(["-q", "--skip-avo-version", "--clean-legacy"])

      stale.each { |dir| expect(Dir).not_to exist dir.to_s }
    end

    it "does not prompt in quiet mode and keeps the files" do
      stale = plant_legacy("avo-fields")
      generate

      stale.each { |dir| expect(Dir).to exist dir.to_s }
    end

    # ~/.claude/skills is shared by every project on the machine. A generator run
    # inside one app must not delete from it — another app may still want those
    # skills, and a test suite must never be able to wipe a real home directory.
    it "never deletes from the shared home skills directory" do
      home_skills = File.expand_path("~/.claude/skills")

      expect(FileUtils).not_to receive(:rm_rf).with(a_string_starting_with(home_skills))

      plant_legacy("avo-fields")
      generate(["-q", "--skip-avo-version", "--clean-legacy"])
    end

    it "reports home leftovers instead of removing them" do
      generator = Generators::Avo::SkillsGenerator.new([], ["--skip-avo-version"], destination_root: Rails.root)
      allow(generator).to receive(:global_legacy_skill_dirs)
        .and_return([File.expand_path("~/.claude/skills/avo-fields")])
      allow(generator).to receive(:legacy_skill_dirs).and_return([])

      output = capture_generator_output { generator.clean_legacy_skills }

      expect(output).to match(/Not removing those/)
      expect(output).to include("~/.claude/skills/avo-fields")
    end

    def capture_generator_output
      original = $stdout
      $stdout = StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = original
    end
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

    # Legacy cleanup is the generator's job now, not something the model has to
    # remember to check on every invocation.
    it "carries no legacy-cleanup instructions" do
      expect(body).not_to match(/Remove any older global install/i)
      expect(body).not_to include("skills/avo-*")
    end

    it "names each resolver error token so the agent can act on it" do
      %w[not_an_app avo_not_locked gem_not_on_disk version_mismatch malformed_lock skills_not_shipped].each do |token|
        expect(body).to include(token)
      end
    end
  end
end
