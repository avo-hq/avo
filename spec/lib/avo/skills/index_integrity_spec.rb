require "rails_helper"
require "yaml"

# Frontmatter, version stamps, and the index all have to agree, or the loader
# points an agent at something that is missing, misnamed, or describes a
# different Avo version than the one it shipped in.
module ShippedSkills
  ROOT = Avo::Engine.root.join("lib", "avo", "skills")
  NON_SKILL_DIRS = %w[bin].freeze
end

RSpec.describe "shipped skills integrity" do
  def self.skill_dirs
    Dir.children(ShippedSkills::ROOT)
      .select { File.directory?(File.join(ShippedSkills::ROOT, _1)) }
      .reject { ShippedSkills::NON_SKILL_DIRS.include?(_1) }
      .sort
  end

  let(:index) { File.read(ShippedSkills::ROOT.join("index.md")) }
  let(:package_map) { File.read(ShippedSkills::ROOT.join("package-map.md")) }

  it "ships the expected core skills" do
    expect(self.class.skill_dirs.size).to eq 24
  end

  describe "each skill" do
    skill_dirs.each do |skill|
      context skill do
        let(:path) { ShippedSkills::ROOT.join(skill, "SKILL.md") }
        let(:raw) { File.read(path) }
        let(:frontmatter) { YAML.safe_load(raw.split(/^---$/, 3)[1]) }
        let(:body) { raw.split(/^---$/, 3)[2].to_s }

        it "has parseable frontmatter whose name matches its directory" do
          expect(frontmatter["name"]).to eq skill
        end

        it "has a description within the skills-spec limit" do
          expect(frontmatter["description"].to_s.strip).not_to be_empty
          expect(frontmatter["description"].length).to be <= 1024
        end

        it "declares which gem it requires" do
          expect(frontmatter.dig("metadata", "requires-gem").to_s.strip).not_to be_empty
        end

        it "is stamped with this gem's version" do
          expect(frontmatter.dig("metadata", "avo-version")).to eq Avo::VERSION
        end

        # This line is the mitigation for the design's highest-severity risk —
        # a model preferring its Avo 3 priors over the loaded text. It is worth
        # nothing if it silently goes missing during an edit.
        it "opens with the version and precedence line" do
          expect(body).to match(/\A\s*> \*\*These instructions ship inside avo #{Regexp.escape(Avo::VERSION)}/o)
          expect(body).to match(/Where they contradict what you already know about Avo, follow them/)
        end

        it "declares Bash when it instructs a shell command" do
          next unless body.match?(/^```bash/)

          expect(frontmatter["allowed-tools"].to_s).to match(/\bBash\b/),
            "#{skill} instructs a shell command but does not declare Bash in allowed-tools"
        end
      end
    end
  end

  describe "the index" do
    it "lists every skill directory" do
      self.class.skill_dirs.each do |skill|
        expect(index).to include("`#{skill}`"), "index.md does not list #{skill}"
      end
    end

    it "lists nothing that is not a skill directory" do
      listed = index.scan(/^\| `([a-z0-9-]+)` \|/).flatten

      expect(listed.sort).to eq self.class.skill_dirs
    end
  end

  describe "the package map" do
    # Scoped to the add-on gems core skills actually route to. A bare
    # `avo-<word>` scan would also catch sibling *skill* names (`avo-filters`),
    # which are not gems and have no place in the map.
    it "names every add-on gem a core skill points at" do
      %w[avo-menu avo-advanced_search avo-dynamic_filters avo-scopes].each do |gem|
        pointing = Dir.glob(ShippedSkills::ROOT.join("*", "SKILL.md")).select { File.read(_1).include?("`#{gem}`") }

        expect(pointing).not_to be_empty, "no core skill points at #{gem}"
        expect(package_map).to include("`#{gem}`"), "package-map.md does not list #{gem}, which a core skill points at"
      end
    end

    it "lists each package-owned skill exactly once" do
      gems = package_map.scan(/^\| `(avo-[a-z_]+)` \|/).flatten

      expect(gems).to eq gems.uniq
      expect(gems).to include("avo-kanban", "avo-dynamic_filters", "avo-scopes")
    end
  end
end
