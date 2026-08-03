require_relative "base_generator"

module Generators
  module Avo
    # Installs the Avo skills loader into the host app.
    #
    # Only the loader is copied — the skills themselves stay inside the gem, which
    # is the whole point: a copied skill tree drifts from the locked Avo version
    # with nothing to refresh it. Re-running this generator refreshes the loader.
    #
    # Deliberately its own namespace rather than part of `avo:install`, so it does
    # not change behavior for apps that already ran the installer.
    class SkillsGenerator < BaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "avo:skills"
      desc "Install the Avo skills loader so coding agents read the instructions that ship with this app's Avo version."

      # Claude Code scans .claude/skills; .agents/skills is the cross-agent
      # convention; .cursor/skills is what Cursor reads. Installing to all three
      # is why the loader is copied rather than symlinked — a symlink into a
      # version-named gem directory breaks on the next `bundle update`.
      TARGETS = {
        "claude" => ".claude/skills/avo",
        "agents" => ".agents/skills/avo",
        "cursor" => ".cursor/skills/avo"
      }.freeze

      # Where a pre-gem install of avo-hq/skills materialized its catalog.
      # `npx skills add` writes project-locally, so the stale copies land in the
      # same directories this generator installs into.
      LEGACY_ROOTS = [
        ".claude/skills",
        ".agents/skills",
        ".cursor/skills"
      ].freeze

      # Checked, reported, and never deleted. This directory is shared by every
      # project on the machine — a skill here may be deliberately installed for
      # a different app, and a generator run inside one project has no business
      # removing it. The user gets the command instead.
      GLOBAL_LEGACY_ROOT = "~/.claude/skills"

      class_option :only, type: :string, desc: "Install one target only (#{TARGETS.keys.join(", ")})"
      class_option :path, type: :string, desc: "Install to this directory instead of the default scan paths"
      class_option :clean_legacy, type: :boolean,
        desc: "Remove skills left by a pre-gem install of avo-hq/skills (skips the prompt either way)"

      def install_loader
        destinations.each do |destination|
          copy_file "skills/SKILL.md", File.join(destination, "SKILL.md")
          install_resolver File.join(destination, "scripts", "avo-skills-resolve")
        end
      end

      # A leftover catalog sits in the same scan directories as the loader and
      # can shadow it, silently serving instructions written for a different Avo
      # version — which is the whole problem this feature removes. Install time
      # is the right place to catch it: it is the one moment we know the user is
      # present and thinking about skills.
      def clean_legacy_skills
        leftovers = legacy_skill_dirs
        global = global_legacy_skill_dirs
        return if leftovers.empty? && global.empty?

        if leftovers.any?
          say "\nFound #{leftovers.length} skill(s) in this project from a previous avo-hq/skills install:"
          leftovers.each { |dir| say "  #{display_path(dir)}", :yellow }
          say "These are not version-pinned and can shadow the skills that ship with your Avo gem."

          if remove_legacy?
            leftovers.each do |dir|
              FileUtils.rm_rf(dir)
              say_status :remove, display_path(dir), :red
            end
          else
            report_kept(leftovers)
          end
        end

        report_global(global) if global.any?
        say "\nIf you installed the Claude Code plugin, remove it with: /plugin uninstall avo-skills"
      end

      no_tasks do
        def remove_legacy?
          return options[:clean_legacy] unless options[:clean_legacy].nil?
          # No TTY to answer, so keep the files and say where they are.
          return false if options[:quiet]

          yes?("\nRemove them? [y/N]")
        end

        def report_kept(leftovers)
          say "\nLeaving them in place. Remove them later with:", :yellow
          say "  rm -rf #{leftovers.map { display_path(_1) }.join(" ")}"
        end

        def report_global(global)
          say "\nAlso found #{global.length} in #{GLOBAL_LEGACY_ROOT}, shared by every project on this machine:", :yellow
          global.each { |dir| say "  #{display_path(dir)}" }
          say "Not removing those — another project may still want them. If not, run:"
          say "  rm -rf #{global.map { display_path(_1) }.join(" ")}"
        end

        def legacy_skill_dirs
          skill_dirs_in(LEGACY_ROOTS.map { File.expand_path(_1, destination_root) })
        end

        def global_legacy_skill_dirs
          skill_dirs_in([File.expand_path(GLOBAL_LEGACY_ROOT)])
        end

        # Only directories that actually look like a skill are eligible — a
        # `rm -rf` driven by a name glob alone is not something to hand a user.
        def skill_dirs_in(roots)
          roots.flat_map { |root| Dir.glob(File.join(root, "avo-*")) }
            .select { |dir| File.directory?(dir) && File.file?(File.join(dir, "SKILL.md")) }
            .uniq
            .sort
        end

        def display_path(dir)
          home = File.expand_path("~")
          return dir.sub(home, "~") if dir.start_with?(home) && !dir.start_with?(File.expand_path(destination_root))

          dir.delete_prefix("#{File.expand_path(destination_root)}/")
        end

        def destinations
          return [options[:path]] if options[:path].present?

          if (only = options[:only]).present?
            target = TARGETS[only]
            raise ::Thor::Error, "Unknown --only value #{only.inspect}. Valid values: #{TARGETS.keys.join(", ")}." if target.nil?

            return [target]
          end

          TARGETS.values
        end

        # The resolver has exactly one source of truth: the copy inside the gem.
        # It is stamped with the gem version on the way out so the installed copy
        # can tell the user when it has fallen behind.
        def install_resolver(destination)
          stamped = resolver_source.sub(
            /^STAMP_VERSION=.*$/,
            %(STAMP_VERSION="#{::Avo::VERSION}")
          )

          create_file destination, stamped
          chmod destination, 0o755
        end

        def resolver_source
          @resolver_source ||= File.read(resolver_path)
        end

        def resolver_path
          File.expand_path("../../avo/skills/bin/avo-skills-resolve", __dir__)
        end
      end
    end
  end
end
