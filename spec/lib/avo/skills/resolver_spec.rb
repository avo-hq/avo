require "rails_helper"
require "tmpdir"
require "fileutils"

# The resolver is the one component that must never guess. Every branch below is
# a state a real app reaches: a Ruby-version mismatch that breaks `bundle show`,
# a stale gem left behind by another install, a lock naming a gem that is gone.
module SkillsResolver
  BIN = Avo::Engine.root.join("lib", "avo", "skills", "bin", "avo-skills-resolve").to_s
  SRC = Avo::Engine.root.join("lib", "avo", "skills")
end

RSpec.describe "avo-skills-resolve" do
  let(:resolver) { SkillsResolver::BIN }
  let(:skills_src) { SkillsResolver::SRC }

  around do |example|
    Dir.mktmpdir("avo-skills-spec") do |dir|
      @root = Pathname.new(dir)
      @gem_home = @root.join("gemhome")
      FileUtils.mkdir_p(@gem_home.join("gems"))
      example.run
    end
  end

  attr_reader :root, :gem_home

  # Feature gems keep VERSION at lib/avo/<namespace>/version.rb; only core uses
  # lib/avo/version.rb. Getting this wrong hard-fails every app with an add-on.
  def make_gem(name, version, declares: version, skills: false, quote: '"')
    namespace = (name == "avo") ? nil : name.delete_prefix("avo-")
    dir = gem_home.join("gems", "#{name}-#{version}")
    lib = [dir, "lib", "avo", namespace].compact.reduce(:join)
    FileUtils.mkdir_p(lib)
    File.write(lib.join("version.rb"), %(module Avo\n  VERSION = #{quote}#{declares}#{quote}\nend\n))

    if skills
      FileUtils.mkdir_p(lib.join("skills"))
      FileUtils.cp(skills_src.join("index.md"), lib.join("skills", "index.md"))
      FileUtils.cp(skills_src.join("package-map.md"), lib.join("skills", "package-map.md"))
    end

    dir
  end

  def app_with(lock_body, name: "app")
    dir = root.join(name)
    FileUtils.mkdir_p(dir)
    File.write(dir.join("Gemfile.lock"), lock_body)
    dir
  end

  def resolve(app)
    stdout = IO.popen(
      {"GEM_HOME" => gem_home.to_s, "GEM_PATH" => gem_home.to_s},
      [resolver, err: [:child, :out]],
      chdir: app.to_s
    ) { _1.read }

    [stdout, $?.exitstatus]
  end

  def gem_lock(*specs)
    "GEM\n  remote: https://rubygems.org/\n  specs:\n" +
      specs.map { "    #{_1}\n" }.join + "\nPLATFORMS\n  ruby\n"
  end

  context "when the gem matches the lock" do
    it "exits 0 and prints the verified skills path" do
      make_gem("avo", "4.1.0", skills: true)
      out, status = resolve(app_with(gem_lock("avo (4.1.0)", "rails (8.1.0)")))

      expect(status).to eq 0
      expect(out).to include("gems/avo-4.1.0/lib/avo/skills")
    end
  end

  # avo-audit_logging declares VERSION with single quotes. Matching only double
  # quotes would fail the assertion on a gem that is perfectly healthy.
  context "when a gem declares VERSION with single quotes" do
    it "reads the version and accepts the gem" do
      make_gem("avo", "4.1.0", skills: true, quote: "'")
      out, status = resolve(app_with(gem_lock("avo (4.1.0)")))

      expect(status).to eq 0
      expect(out).not_to include("version_mismatch")
    end
  end

  context "when the resolved gem is a different version than the lock" do
    it "refuses the path rather than loading stale instructions" do
      make_gem("avo", "4.0.21", declares: "4.0.0.beta.59", skills: true)
      out, status = resolve(app_with(gem_lock("avo (4.0.21)")))

      expect(status).not_to eq 0
      expect(out).to include("version_mismatch")
      expect(out).to include("4.0.0.beta.59")
    end
  end

  context "when there is no Gemfile.lock" do
    it "stops with not_an_app" do
      out, status = resolve(root.join("bare").tap { FileUtils.mkdir_p(_1) })

      expect(status).not_to eq 0
      expect(out).to include("not_an_app")
    end
  end

  context "when the lock has no avo entry" do
    it "stops with avo_not_locked" do
      out, status = resolve(app_with(gem_lock("rails (8.1.0)")))

      expect(status).not_to eq 0
      expect(out).to include("avo_not_locked")
    end
  end

  context "when the locked gem is not installed" do
    it "stops with gem_not_on_disk" do
      out, status = resolve(app_with(gem_lock("avo (9.9.9)")))

      expect(status).not_to eq 0
      expect(out).to include("gem_not_on_disk")
    end
  end

  context "when avo predates gem-shipped skills" do
    it "stops with skills_not_shipped and names the minimum version" do
      make_gem("avo", "3.9.0", skills: false)
      out, status = resolve(app_with(gem_lock("avo (3.9.0)")))

      expect(status).not_to eq 0
      expect(out).to include("skills_not_shipped")
      expect(out).to match(/Skills ship from avo \d+\.\d+\.\d+ onward/)
    end
  end

  context "when the lock contains a hostile gem name" do
    it "refuses to build a path from it" do
      make_gem("avo", "4.1.0", skills: true)
      out, status = resolve(app_with(gem_lock("avo (4.1.0)", "avo-../../../etc (1.0.0)")))

      expect(status).not_to eq 0
      expect(out).to include("malformed_lock")
    end
  end

  # `avo-` on rubygems.org is unreserved, and whatever the loader prints becomes
  # instructions the agent follows. Naming alone must not earn that authority.
  context "when an avo-prefixed gem is not in the package map" do
    it "never reads or prints its skills" do
      make_gem("avo", "4.1.0", skills: true)
      squatter = make_gem("avo-evil", "1.0.0", skills: true)
      File.write(squatter.join("lib", "avo", "evil", "skills", "index.md"), "EVIL INSTRUCTIONS\n")

      out, status = resolve(app_with(gem_lock("avo (4.1.0)", "avo-evil (1.0.0)")))

      expect(status).to eq 0
      expect(out).not_to include("EVIL INSTRUCTIONS")
      expect(out).not_to include("avo-evil")
    end
  end

  context "with an allowlisted package gem installed" do
    it "lists it with its index path" do
      make_gem("avo", "4.1.0", skills: true)
      make_gem("avo-kanban", "1.2.0", skills: true)

      out, status = resolve(app_with(gem_lock("avo (4.1.0)", "avo-kanban (1.2.0)")))

      expect(status).to eq 0
      expect(out).to include("avo-kanban 1.2.0")
    end
  end

  context "with an allowlisted package gem absent" do
    it "names the gem without ever printing a path for it" do
      make_gem("avo", "4.1.0", skills: true)
      out, status = resolve(app_with(gem_lock("avo (4.1.0)")))

      expect(status).to eq 0
      expect(out).to match(/^- \*\*avo-kanban\*\*/)
      expect(out).not_to include("gems/avo-kanban")
    end
  end

  # The packager.dev credential lives in bundler config. Any code path that
  # relays bundler output writes a license key into the agent's transcript.
  context "credential hygiene" do
    it "emits no bundler configuration on stdout or stderr" do
      make_gem("avo", "4.1.0", skills: true)
      app = app_with(gem_lock("avo (4.1.0)"))
      FileUtils.mkdir_p(app.join(".bundle"))
      File.write(app.join(".bundle", "config"), %(---\nBUNDLE_PACKAGER__DEV: "SENTINELTOKEN123"\n))

      out, = resolve(app)

      expect(out).not_to include("SENTINELTOKEN123")
      expect(out).not_to include("BUNDLE_")
    end
  end
end
