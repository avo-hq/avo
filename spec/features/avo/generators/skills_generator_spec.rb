require "rails_helper"
require "rails/generators"
require "tmpdir"
# lib/generators is outside the Zeitwerk root, so the class is only defined once
# something invokes it. Requiring it keeps the unit-level examples order-independent.
require "generators/avo/skills_generator"

RSpec.feature "skills generator", type: :feature, acquire_lock: :generator do
  let(:targets) { %w[.claude/skills/avo .agents/skills/avo .cursor/skills/avo] }

  def generate(args = ["-q", "--skip-avo-version"])
    Rails::Generators.invoke("avo:skills", args, {destination_root: Rails.root})
  end

  def cleanup
    %w[.claude .agents .cursor].each { |dir| FileUtils.rm_rf(Rails.root.join(dir)) }
  end

  after { cleanup }

  it "installs the loader into every scan path" do
    generate

    targets.each { |target| expect(File).to exist Rails.root.join(target, "SKILL.md").to_s }
  end

  # 250 lines of shell in someone's repo is a fair thing to be suspicious of,
  # and a copy is one more artifact that can drift. The resolver stays in the
  # gem; the loader tells the agent how to reach it.
  it "installs nothing but the SKILL.md" do
    generate

    targets.each do |target|
      installed = Dir.glob(Rails.root.join(target, "**", "*"), File::FNM_DOTMATCH).select { File.file?(_1) }

      expect(installed.map { File.basename(_1) }).to eq ["SKILL.md"]
    end
  end

  it "copies rather than symlinks, so bundle update cannot break the link" do
    generate

    targets.each { |target| expect(File).not_to be_symlink Rails.root.join(target, "SKILL.md").to_s }
  end

  it "refreshes an edited loader when re-run" do
    generate

    loader = Rails.root.join(".claude/skills/avo/SKILL.md")
    File.write(loader, "# stale local edit
")
    generate(["-q", "--skip-avo-version", "--force"])

    expect(File.read(loader)).to eq File.read(Avo::Engine.root.join("lib/generators/avo/templates/skills/SKILL.md"))
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

  describe "--global" do
    let(:global_targets) { %w[.claude/skills/avo .agents/skills/avo .cursor/skills/avo] }

    around do |example|
      Dir.mktmpdir("fake-home") do |home|
        @home = home
        original = ENV["HOME"]
        ENV["HOME"] = home
        example.run
      ensure
        ENV["HOME"] = original
      end
    end

    it "installs to the home directory, not the app" do
      generate(["-q", "--skip-avo-version", "--global"])

      global_targets.each { |t| expect(File).to exist File.join(@home, t, "SKILL.md") }
      global_targets.each { |t| expect(File).not_to exist Rails.root.join(t, "SKILL.md").to_s }
    end

    # One copy serves every project, so it must be the same bytes the gem ships —
    # otherwise it would report itself stale everywhere.
    it "is otherwise the same file the app install writes" do
      generate(["-q", "--skip-avo-version", "--global"])

      global = File.read(File.join(@home, ".claude/skills/avo/SKILL.md"))
      expect(global).to eq File.read(Avo::Engine.root.join("lib/generators/avo/templates/skills/SKILL.md"))
    end
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

    # These exercise the reporting directly, so they run against their own temp
    # root — the dummy app is shared with every other generator spec.
    describe "reporting" do
      around do |example|
        Dir.mktmpdir("skills-legacy") do |dir|
          @sandbox = dir
          example.run
        end
      end

      def plant_in_sandbox(*names, root:)
        names.each do |name|
          dir = File.join(@sandbox, root, name)
          FileUtils.mkdir_p(dir)
          File.write(File.join(dir, "SKILL.md"), "---\nname: #{name}\n---\n")
        end
      end

      def report(args = ["--skip-avo-version", "--no-clean-legacy"])
        generator = Generators::Avo::SkillsGenerator.new([], args, destination_root: @sandbox)
        yield generator if block_given?
        capture_generator_output { generator.clean_legacy_skills }
      end

      # The full catalog is 35 skills per scan path. Listing them individually
      # buries the prompt under a hundred lines of noise.
      it "summarizes by directory rather than listing every skill" do
        %w[.claude/skills .agents/skills].each do |root|
          plant_in_sandbox(*(1..35).map { "avo-skill-#{_1}" }, root: root)
        end

        output = report

        expect(output).to include("Found 70 skills")
        expect(output).to match(%r{^\s+\.claude/skills/\s+35$})
        expect(output).to match(%r{^\s+\.agents/skills/\s+35$})
        expect(output).not_to include("avo-skill-1\n")
        expect(output.lines.count).to be < 15
      end

      it "offers one glob per directory instead of every path" do
        plant_in_sandbox("avo-fields", "avo-kanban", root: ".claude/skills")

        output = report

        expect(output).to include("rm -rf .claude/skills/avo-*")
        expect(output).not_to include("avo-fields avo-kanban")
      end

      it "reports home leftovers instead of removing them" do
        output = report(["--skip-avo-version"]) do |generator|
          allow(generator).to receive(:global_legacy_skill_dirs)
            .and_return([File.expand_path("~/.claude/skills/avo-fields")])
          allow(generator).to receive(:legacy_skill_dirs).and_return([])
        end

        expect(output).to match(/Not removing those/)
        expect(output).to match(%r{^\s+~/\.claude/skills/\s+1$})
        expect(output).to include("rm -rf ~/.claude/skills/avo-*")
      end
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

    it "teaches the agent how to find the gem" do
      expect(body).to match(/bundle show avo/)
      expect(body).to match(/gem which avo/)
      expect(body).to match(%r{lib/avo/skills/bin/avo-skills-resolve})
    end

    it "warns that gem which can return the wrong version" do
      expect(body).to match(/different version than this app locked/)
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
