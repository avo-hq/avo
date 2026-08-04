require "rails_helper"

# The skills only work if they actually ship. Nothing else in this gem asserts
# `spec.files` content, and a packaging miss is invisible until after a release.
RSpec.describe "shipped skills packaging" do
  let(:gem_root) { Avo::Engine.root }
  let(:skills_root) { gem_root.join("lib", "avo", "skills") }

  let(:packaged) do
    Dir.chdir(gem_root) { Gem::Specification.load("avo.gemspec").files }
  end

  def relative(path)
    Pathname.new(path).relative_path_from(gem_root).to_s
  end

  it "packages every SKILL.md on disk" do
    on_disk = Dir.glob(skills_root.join("**", "SKILL.md")).map { relative(_1) }

    expect(on_disk).not_to be_empty
    expect(packaged).to include(*on_disk)
  end

  it "packages the index, the package map, and the resolver" do
    %w[index.md package-map.md bin/avo-skills-resolve].each do |file|
      expect(packaged).to include("lib/avo/skills/#{file}")
    end
  end

  it "packages every bundled skill asset" do
    assets = Dir.glob(skills_root.join("*", "scripts", "*")).map { relative(_1) }

    expect(assets).not_to be_empty
    expect(packaged).to include(*assets)
  end

  # Nine gemspecs in the family reject symlinked files from spec.files. A
  # symlink here would ship from core and silently vanish from those gems.
  it "contains no symlinks" do
    symlinks = Dir.glob(skills_root.join("**", "*"), File::FNM_DOTMATCH).select { File.symlink?(_1) }

    expect(symlinks).to be_empty
  end

  it "ships the resolver executable" do
    expect(File).to be_executable skills_root.join("bin", "avo-skills-resolve").to_s
  end

  # Zeitwerk eager-loads lib/ under Rails and cannot constantize a hyphenated
  # skill directory, so the tree must stay ignored. Guarding the ignore rather
  # than the crash keeps the failure legible.
  # Zeitwerk would infer `Avo::Skills` from lib/avo/skills/ and then die trying
  # to constantize its hyphenated children. Asserting the constant never comes
  # into being tests the outcome rather than the loader's internals.
  it "is invisible to Zeitwerk" do
    expect(defined?(Avo::Skills)).to be_nil
    expect { Avo.const_get(:Skills) }.to raise_error(NameError)
  end
end
