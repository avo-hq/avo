require "rails_helper"
require "rails/generators"
require "tmpdir"
# lib/generators is outside the Zeitwerk root, so the class is only defined once
# something invokes it. Requiring it keeps the unit-level examples order-independent.
require "generators/avo/skills_generator"

# The generator has no flags to reach past the panel with, so these drive the
# real thing: a fake tty on $stdin/$stdout, and the keys someone would press.
class FakeKeyboard
  KEYS = {
    up: ["\e", "[A"], down: ["\e", "[B"], back: ["\e", "[D"],
    space: [" "], enter: ["\r"], cancel: ["q"]
  }.freeze

  def initialize(keys)
    @chars = keys.flat_map { KEYS.fetch(_1) }
  end

  def getch = @chars.shift

  def read_nonblock(_n) = @chars.shift

  def tty? = true
end

class FakeTerminal < StringIO
  def tty? = true
end

RSpec.feature "skills generator", type: :feature, acquire_lock: :generator do
  let(:targets) { %w[.claude/skills/avo .agents/skills/avo .cursor/skills/avo] }

  # Screens, in order: where, [project leftovers], [shared leftovers], agents,
  # [link], confirm. The bracketed ones appear only when they apply, so every
  # key sequence below is written against exactly the screens that example gets.
  let(:all_defaults) { [:enter, :enter, :enter, :enter] }

  # ~/.claude/skills is scanned for leftovers, so a real home directory would
  # make the screen list depend on whose machine the suite runs on.
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

  def generate(keys = all_defaults, args: [])
    original_in, original_out = $stdin, $stdout
    $stdin = FakeKeyboard.new(keys)
    $stdout = FakeTerminal.new
    Rails::Generators.invoke("avo:skills", ["--skip-avo-version", *args], {destination_root: Rails.root})
    $stdout.string
  ensure
    $stdin, $stdout = original_in, original_out
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

  # One real file, linked from the rest: an update is then a single edit, and
  # the three directories cannot drift apart.
  it "writes one real file and symlinks the others to it" do
    generate

    expect(File).not_to be_symlink Rails.root.join(".agents/skills/avo/SKILL.md").to_s
    expect(File).to be_symlink Rails.root.join(".claude/skills/avo/SKILL.md").to_s
    expect(File).to be_symlink Rails.root.join(".cursor/skills/avo/SKILL.md").to_s
  end

  # Relative, so the link still resolves after the repo is cloned somewhere else.
  it "links relatively, not to this machine's absolute path" do
    generate

    expect(File.readlink(Rails.root.join(".claude/skills/avo/SKILL.md").to_s)).not_to start_with "/"
  end

  it "reads as the same loader through every directory" do
    generate

    bodies = targets.map { File.read(Rails.root.join(_1, "SKILL.md")) }

    expect(bodies.uniq.length).to eq 1
  end

  it "refreshes an edited loader when re-run" do
    generate

    loader = Rails.root.join(".agents/skills/avo/SKILL.md")
    File.write(loader, "# stale local edit\n")
    generate(all_defaults, args: ["--force"])

    expect(File.read(loader)).to eq File.read(Avo::Engine.root.join("lib/generators/avo/templates/skills/SKILL.md"))
  end

  describe "answering the panel" do
    it "installs only the agents left ticked" do
      # untick .agents, move to .cursor, untick it, leaving .claude
      generate([:enter, :space, :down, :down, :space, :enter, :enter])

      expect(File).to exist Rails.root.join(".claude/skills/avo/SKILL.md").to_s
      expect(File).not_to exist Rails.root.join(".agents/skills/avo/SKILL.md").to_s
      expect(File).not_to exist Rails.root.join(".cursor/skills/avo/SKILL.md").to_s
    end

    # Nothing to keep in step with one directory, so the question is not worth
    # a screen.
    it "does not ask about linking when only one agent is picked" do
      output = generate([:enter, :space, :down, :down, :space, :enter, :enter])

      expect(output).not_to include "How should the extra directories be written?"
    end

    it "asks about linking once more than one agent is picked" do
      expect(generate).to include "How should the extra directories be written?"
    end

    it "writes separate copies when asked to" do
      generate([:enter, :enter, :down, :enter, :enter])

      targets.each { |target| expect(File).not_to be_symlink Rails.root.join(target, "SKILL.md").to_s }
      targets.each { |target| expect(File).to exist Rails.root.join(target, "SKILL.md").to_s }
    end

    it "installs nothing when cancelled" do
      generate([:cancel])

      targets.each { |target| expect(File).not_to exist Rails.root.join(target, "SKILL.md").to_s }
    end

    it "says so rather than failing silently when cancelled" do
      expect(generate([:cancel])).to include "Cancelled. Nothing was installed."
    end
  end

  # The last screen, so nothing is written before the user has seen what the
  # answers add up to.
  describe "the confirm screen" do
    it "lists the answers back before installing" do
      output = generate

      expect(output).to include "Run the installation?"
      expect(output).to match(/Install to\s+this app/)
      expect(output).to match(/Directories\s+\.agents\/skills, \.claude\/skills, \.cursor\/skills/)
      expect(output).to match(/Extra copies\s+symlinked to \.agents\/skills/)
    end

    it "reflects the answers actually given, not the defaults" do
      output = generate([:down, :enter, :enter, :down, :enter])

      expect(output).to match(/Install to\s+this machine/)
      expect(output).to match(/Extra copies\s+written separately/)
    end

    it "omits the copies row when there is only one directory" do
      output = generate([:enter, :space, :down, :down, :space, :enter, :enter])

      expect(output).not_to include "Extra copies"
    end

    it "installs nothing when the answer is no" do
      generate([:enter, :enter, :enter, :down, :enter])

      targets.each { |target| expect(File).not_to exist Rails.root.join(target, "SKILL.md").to_s }
    end

    it "goes back from it to change an answer" do
      # confirm -> back to link -> pick separate copies -> confirm
      generate([:enter, :enter, :enter, :back, :down, :enter, :enter])

      targets.each { |target| expect(File).not_to be_symlink Rails.root.join(target, "SKILL.md").to_s }
    end
  end

  # Windows without developer mode, and some CI checkouts, cannot create one.
  # A real file beats a broken install.
  it "falls back to copying when the filesystem has no symlinks" do
    generator = Generators::Avo::SkillsGenerator.new([], ["--skip-avo-version"], destination_root: Rails.root.to_s)
    allow(generator).to receive(:symlinks_supported?).and_return(true)
    allow(File).to receive(:symlink).and_raise(Errno::EPERM)

    generator.install_loader

    targets.each { |target| expect(File).to exist Rails.root.join(target, "SKILL.md").to_s }
    targets.each { |target| expect(File).not_to be_symlink Rails.root.join(target, "SKILL.md").to_s }
  end

  describe "installing for the whole machine" do
    let(:machine_keys) { [:down, :enter, :enter, :enter, :enter] }

    it "installs to the home directory, not the app" do
      generate(machine_keys)

      targets.each { |t| expect(File).to exist File.join(@home, t, "SKILL.md") }
      targets.each { |t| expect(File).not_to exist Rails.root.join(t, "SKILL.md").to_s }
    end

    # One copy serves every project, so it must be the same bytes the gem ships —
    # otherwise it would report itself stale everywhere.
    it "is otherwise the same file the app install writes" do
      generate(machine_keys)

      machine = File.read(File.join(@home, ".claude/skills/avo/SKILL.md"))
      expect(machine).to eq File.read(Avo::Engine.root.join("lib/generators/avo/templates/skills/SKILL.md"))
    end

    # The link is between two directories under the same home, so it must not
    # reach back into the app root that Thor was pointed at.
    it "links between the home directories, not back into the app" do
      generate(machine_keys)

      link = File.join(@home, ".claude/skills/avo/SKILL.md")

      expect(File).to be_symlink link
      expect(File.realpath(link)).to eq File.realpath(File.join(@home, ".agents/skills/avo/SKILL.md"))
    end

    it "shows the home paths on the confirm screen" do
      expect(generate(machine_keys)).to match(%r{Directories\s+~/\.agents/skills})
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

    def plant_shared(*names)
      names.map do |name|
        dir = File.join(@home, ".claude/skills", name)
        FileUtils.mkdir_p(dir)
        File.write(File.join(dir, "SKILL.md"), "---\nname: #{name}\n---\n")
        dir
      end
    end

    # One extra screen with leftovers present, so one extra answer.
    let(:clean_them) { [:enter, :enter, :enter, :enter, :enter] }
    let(:keep_them) { [:enter, :down, :enter, :enter, :enter, :enter] }

    it "asks only when there is something to remove" do
      plant_legacy("avo-fields")

      expect(generate(clean_them)).to include "left by an earlier install?"
    end

    it "does not ask when there is nothing to remove" do
      expect(generate).not_to include "left by an earlier install?"
    end

    it "removes a leftover catalog when asked" do
      stale = plant_legacy("avo-fields", "avo-kanban")
      generate(clean_them)

      stale.each { |dir| expect(Dir).not_to exist dir.to_s }
    end

    it "leaves the loader it just installed alone" do
      plant_legacy("avo-fields")
      generate(clean_them)

      expect(File).to exist Rails.root.join(".claude/skills/avo/SKILL.md").to_s
    end

    it "keeps leftovers when told not to clean" do
      stale = plant_legacy("avo-fields")
      generate(keep_them)

      stale.each { |dir| expect(Dir).to exist dir.to_s }
    end

    it "names the removal on the confirm screen" do
      plant_legacy("avo-fields", "avo-kanban")

      expect(generate(clean_them)).to match(/Remove\s+2 skills left in this project/)
    end

    # A `rm -rf` driven by a name glob alone is not something to hand a user.
    it "ignores an avo-prefixed directory that is not a skill" do
      unrelated = Rails.root.join(".claude/skills/avo-notes")
      FileUtils.mkdir_p(unrelated)
      File.write(unrelated.join("README.md"), "not a skill")

      generate

      expect(Dir).to exist unrelated.to_s
    end

    it "cleans every scan directory, not just Claude's" do
      stale = %w[.claude/skills .agents/skills .cursor/skills].flat_map { plant_legacy("avo-fields", root: _1) }
      generate(clean_them)

      stale.each { |dir| expect(Dir).not_to exist dir.to_s }
    end

    # A run with no terminal never showed the question, so nobody declined it.
    it "keeps them when there was no terminal to ask on" do
      stale = plant_legacy("avo-fields")
      Rails::Generators.invoke("avo:skills", ["--skip-avo-version", "-q"], {destination_root: Rails.root})

      stale.each { |dir| expect(Dir).to exist dir.to_s }
    end

    # ~/.claude/skills is shared with every other project, so it gets its own
    # question rather than riding along on the project one.
    describe "the shared home directory" do
      it "asks about it separately" do
        plant_shared("avo-fields")

        expect(generate(clean_them)).to include "shared by every project on this machine"
      end

      it "removes them when asked" do
        stale = plant_shared("avo-fields", "avo-kanban")
        generate(clean_them)

        stale.each { |dir| expect(Dir).not_to exist dir.to_s }
      end

      it "keeps them when told not to" do
        stale = plant_shared("avo-fields")
        generate(keep_them)

        stale.each { |dir| expect(Dir).to exist dir.to_s }
      end

      it "asks twice when both places have leftovers" do
        plant_legacy("avo-fields")
        plant_shared("avo-kanban")
        output = generate([:enter, :enter, :enter, :enter, :enter, :enter])

        expect(output).to include "left by an earlier install?"
        expect(output).to include "shared by every project on this machine"
      end

      it "never removes them on a run with no terminal to ask on" do
        stale = plant_shared("avo-fields")
        Rails::Generators.invoke("avo:skills", ["--skip-avo-version", "-q"], {destination_root: Rails.root})

        stale.each { |dir| expect(Dir).to exist dir.to_s }
      end
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

      # No terminal here, so the generator takes the defaults and keeps them,
      # which is exactly the branch that reports.
      def report
        generator = Generators::Avo::SkillsGenerator.new([], ["--skip-avo-version"], destination_root: @sandbox)
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

        expect(output).to include("Leaving 70 skills in place")
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

      it "reports the shared ones under a tilde, not an absolute path" do
        output = report do |generator|
          allow(generator).to receive(:shared_legacy_skill_dirs)
            .and_return([File.expand_path("~/.claude/skills/avo-fields")])
          allow(generator).to receive(:legacy_skill_dirs).and_return([])
        end

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
