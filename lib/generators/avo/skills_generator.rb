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

      class_option :global, type: :boolean,
        desc: "Install to your home directory instead of this app, so every Avo project on this machine shares one loader"
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
          say "\nFound #{pluralize_skills(leftovers.length)} in this project from a previous avo-hq/skills install:"
          by_directory(leftovers).each { |dir, count| say "  #{dir}#{" " * padding(dir)}#{count}", :yellow }
          say "These are not version-pinned and can shadow the skills that ship with your Avo gem."

          if remove_legacy?
            by_directory(leftovers).each do |dir, count|
              leftovers.select { |path| display_dir(path) == dir }.each { |path| FileUtils.rm_rf(path) }
              say_status :remove, "#{dir} (#{pluralize_skills(count)})", :red
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
          say "  #{removal_command(leftovers)}"
        end

        def report_global(global)
          say "\nAlso found #{pluralize_skills(global.length)} in #{GLOBAL_LEGACY_ROOT}, shared by every project on this machine:", :yellow
          by_directory(global).each { |dir, count| say "  #{dir}#{" " * padding(dir)}#{count}" }
          say "Not removing those — another project may still want them. If not, run:"
          say "  #{removal_command(global)}"
        end

        # One glob per directory rather than one path per skill: with the full
        # catalog installed this is the difference between a readable command
        # and 35 pasted paths.
        def removal_command(dirs)
          "rm -rf #{by_directory(dirs).keys.map { "#{_1}avo-*" }.join(" ")}"
        end

        # Directory => how many legacy skills sit in it, so a full catalog
        # reports three lines instead of a hundred.
        def by_directory(dirs)
          dirs.group_by { display_dir(_1) }.transform_values(&:count).sort.to_h
        end

        def display_dir(path)
          "#{display_path(File.dirname(path))}/"
        end

        def padding(dir)
          [2, 28 - dir.length].max
        end

        def pluralize_skills(count)
          "#{count} skill#{"s" unless count == 1}"
        end

        # Cleanup is scoped to wherever this run installs. A project install must
        # not delete from the home directory another project may still rely on;
        # a --global install is exactly the case where home is fair game.
        def legacy_skill_dirs
          roots = options[:global] ? [File.expand_path(GLOBAL_LEGACY_ROOT)] : LEGACY_ROOTS.map { File.expand_path(_1, destination_root) }
          skill_dirs_in(roots)
        end

        def global_legacy_skill_dirs
          return [] if options[:global]

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

        # The loader holds no per-project state — it finds the app by walking up
        # from the working directory at run time — so one global copy serves
        # every Avo project on the machine, each resolving its own lock.
        def destinations
          return [options[:path]] if options[:path].present?

          return roots.map { |target| File.expand_path("~/#{target}") } if options[:global]

          if (only = options[:only]).present?
            target = TARGETS[only]
            raise ::Thor::Error, "Unknown --only value #{only.inspect}. Valid values: #{TARGETS.keys.join(", ")}." if target.nil?

            return [target]
          end

          TARGETS.values
        end

        def roots
          return [TARGETS.fetch(options[:only])] if options[:only].present? && TARGETS.key?(options[:only])

          TARGETS.values
        end

        # The resolver has exactly one source of truth: the copy inside the gem.
        # It is stamped with the gem version on the way out so the installed copy
        # can tell the user when it has fallen behind.
        def install_resolver(destination)
          # A global copy stays unstamped. The staleness check compares its stamp
          # against the resolved gem, which is meaningful for one app and pure
          # noise across four on different versions; the resolver already treats
          # the unstamped sentinel as "do not warn".
          stamped = if options[:global]
            resolver_source
          else
            resolver_source.sub(/^STAMP_VERSION=.*$/, %(STAMP_VERSION="#{::Avo::VERSION}"))
          end

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
