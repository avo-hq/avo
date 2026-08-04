require "tmpdir"
require_relative "base_generator"
require_relative "skills_install_panel"

module Generators
  module Avo
    # Installs the Avo skills loader into the host app.
    #
    # Only the loader is written — the skills themselves stay inside the gem,
    # which is the point: a copied skill tree drifts from the locked Avo version
    # with nothing to refresh it.
    #
    # There is one way to run this and it asks. No flags: a flag per question is
    # a second surface to document, keep in step with the screens, and get wrong.
    class SkillsGenerator < BaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "avo:skills"
      desc "Install the Avo skills loader so coding agents read the instructions that ship with this app's Avo version."

      # Claude Code scans .claude/skills; .agents/skills is the cross-agent
      # convention; .cursor/skills is what Cursor reads.
      AGENTS = {
        "agents" => {dir: ".agents/skills/avo", label: ".agents/skills", hint: "Codex, Gemini CLI, Goose, Amp, OpenCode"},
        "claude" => {dir: ".claude/skills/avo", label: ".claude/skills", hint: "Claude Code"},
        "cursor" => {dir: ".cursor/skills/avo", label: ".cursor/skills", hint: "Cursor"}
      }.freeze

      # The copy the others link to. Vendor-neutral on purpose: the real file
      # should not live in a directory named after one tool.
      CANONICAL = "agents"

      # Where a pre-gem install of avo-hq/skills left its catalog, and where an
      # early 4.1.1 install left the resolver we no longer ship.
      LEGACY_ROOTS = [".claude/skills", ".agents/skills", ".cursor/skills"].freeze
      GLOBAL_LEGACY_ROOT = "~/.claude/skills"

      def install_loader
        return if answers.cancelled?

        canonical = nil
        destinations.each do |dir|
          if canonical.nil? || !link?
            copy_file "skills/SKILL.md", File.join(dir, "SKILL.md")
            canonical ||= dir
          else
            link_or_copy(canonical, dir)
          end
        end
      end

      def clean_legacy_skills
        return if answers.cancelled?

        remove_or_report(legacy_skill_dirs, remove: remove_legacy?)
        remove_or_report(shared_legacy_skill_dirs, remove: remove_shared_legacy?)
      end

      no_tasks do
        def answers
          @answers ||= SkillsInstallPanel.interactive? ? ask_the_user : take_the_defaults
        end

        # Answering "No" on the last screen is a cancel — the user was shown what
        # was about to happen and declined it.
        def ask_the_user
          result = SkillsInstallPanel.new(screens, defaults: defaults).run
          return declined if result.cancelled? || result[:confirm] == false

          SkillsInstallPanel::Result.new(defaults.merge(result.answers), false)
        end

        def declined
          say("Cancelled. Nothing was installed.", :yellow)
          SkillsInstallPanel::Result.new({}, true)
        end

        # No terminal to ask on — piped, or a test run. Install what the screens
        # recommend, but neither destructive one: nobody was there to decline.
        def take_the_defaults
          SkillsInstallPanel::Result.new(defaults.merge(clean_legacy: false, clean_shared_legacy: false), false)
        end

        def defaults
          {
            where: "app", agents: AGENTS.keys, link: symlinks_supported?,
            clean_legacy: true, clean_shared_legacy: true, confirm: true
          }
        end

        # A cleanup screen only when there is something to remove there, and the
        # link screen only once there is more than one directory to keep in step.
        def screens
          list = [where_screen]
          list << legacy_screen if legacy_skill_dirs.any?
          list << shared_legacy_screen if shared_legacy_skill_dirs.any?
          list << agents_screen
          list << link_screen if symlinks_supported?
          list << confirm_screen
          list
        end

        def where_screen
          SkillsInstallPanel::Screen.new(
            key: :where, kind: :radio, title: "Where should the Avo skills loader go?",
            hint: "It finds the gem from the working directory, so one copy serves every project correctly.",
            options: [
              SkillsInstallPanel::Option.new(key: "app", label: "This app", hint: "commit it, your team gets it", recommended: true),
              SkillsInstallPanel::Option.new(key: "machine", label: "This machine", hint: "one install, every Avo project")
            ]
          )
        end

        def legacy_screen
          SkillsInstallPanel::Screen.new(
            key: :clean_legacy, kind: :radio,
            title: "Remove the #{pluralize_skills(legacy_skill_dirs.length)} left by an earlier install?",
            hint: "They are not version-pinned and can shadow the skills that ship with your gem.",
            options: [
              SkillsInstallPanel::Option.new(key: true, label: "Yes, remove them", recommended: true),
              SkillsInstallPanel::Option.new(key: false, label: "No, leave them")
            ]
          )
        end

        # Kept a separate question from the project one: this directory is shared
        # with every other project on the machine, and that is worth its own yes.
        def shared_legacy_screen
          SkillsInstallPanel::Screen.new(
            key: :clean_shared_legacy, kind: :radio,
            title: "Remove the #{pluralize_skills(shared_legacy_skill_dirs.length)} in #{GLOBAL_LEGACY_ROOT}?",
            hint: "That directory is shared by every project on this machine, not just this one.",
            options: [
              SkillsInstallPanel::Option.new(key: true, label: "Yes, remove them", recommended: true),
              SkillsInstallPanel::Option.new(key: false, label: "No, leave them")
            ]
          )
        end

        def confirm_screen
          SkillsInstallPanel::Screen.new(
            key: :confirm, kind: :radio, title: "Run the installation?", hint: nil,
            summary: ->(a) { summary_lines(a) },
            options: [
              SkillsInstallPanel::Option.new(key: true, label: "Yes, install", recommended: true),
              SkillsInstallPanel::Option.new(key: false, label: "No, cancel")
            ]
          )
        end

        def summary_lines(a)
          agents = Array(a[:agents]).select { AGENTS.key?(_1) }
          root = (a[:where] == "machine") ? "~/" : ""
          lines = [
            summary_row("Install to", (a[:where] == "machine") ? "this machine (your home directory)" : "this app"),
            summary_row("Directories", agents.map { "#{root}#{AGENTS.fetch(_1)[:label]}" }.join(", "))
          ]
          lines << summary_row("Extra copies", a[:link] ? "symlinked to #{root}#{AGENTS.fetch(CANONICAL)[:label]}" : "written separately") if agents.length > 1
          lines << summary_row("Remove", "#{pluralize_skills(legacy_skill_dirs.length)} left in this project") if legacy_skill_dirs.any? && a[:clean_legacy]
          lines << summary_row("Remove", "#{pluralize_skills(shared_legacy_skill_dirs.length)} in #{GLOBAL_LEGACY_ROOT}") if shared_legacy_skill_dirs.any? && a[:clean_shared_legacy]
          lines
        end

        def summary_row(label, value) = "#{label.ljust(14)}#{value}"

        def agents_screen
          SkillsInstallPanel::Screen.new(
            key: :agents, kind: :checkbox, title: "Which agents should read it?", hint: nil,
            options: AGENTS.map { |key, a| SkillsInstallPanel::Option.new(key: key, label: a[:label], hint: a[:hint]) }
          )
        end

        def link_screen
          SkillsInstallPanel::Screen.new(
            key: :link, kind: :radio, title: "How should the extra directories be written?",
            hint: "One real file keeps them identical and makes an update a single edit.",
            options: [
              SkillsInstallPanel::Option.new(key: true, label: "Symlink to one copy", hint: ".#{CANONICAL}/skills holds the file", recommended: true),
              SkillsInstallPanel::Option.new(key: false, label: "Separate copies", hint: "use when symlinks are awkward")
            ],
            visible_when: ->(a) { Array(a[:agents]).length > 1 }
          )
        end

        def destinations
          dirs = selected_agent_keys.map { |k| AGENTS.fetch(k)[:dir] }
          global? ? dirs.map { File.expand_path("~/#{_1}") } : dirs
        end

        # Canonical first, so it is the one written as a real file.
        def selected_agent_keys
          keys = Array(answers[:agents]).select { AGENTS.key?(_1) }
          keys = AGENTS.keys if keys.empty?
          keys.sort_by { |k| (k == CANONICAL) ? 0 : 1 }
        end

        def global? = answers[:where] == "machine"

        def link? = !!answers[:link]

        def remove_legacy? = !!answers[:clean_legacy]

        def remove_shared_legacy? = !!answers[:clean_shared_legacy]

        def remove_or_report(dirs, remove:)
          return if dirs.empty?

          if remove
            by_directory(dirs).each do |dir, count|
              dirs.select { |p| display_dir(p) == dir }.each { |p| FileUtils.rm_rf(p) }
              say_status :remove, "#{dir} (#{pluralize_skills(count)})", :red
            end
          else
            # By directory, never one line per skill: the full catalog is 35 per
            # scan path, and listing them buries everything else.
            say "\nLeaving #{pluralize_skills(dirs.length)} in place:", :yellow
            by_directory(dirs).each { |dir, count| say "  #{dir}  #{count}" }
            say "Remove them later with:"
            say "  #{removal_command(dirs)}"
          end
        end

        # Probed, not assumed: Windows without developer mode, and some CI
        # checkouts, cannot create one. A real file beats a broken install.
        def symlinks_supported?
          return @symlinks_supported if defined?(@symlinks_supported)

          @symlinks_supported =
            begin
              Dir.mktmpdir do |dir|
                File.write(File.join(dir, "target"), "x")
                File.symlink(File.join(dir, "target"), File.join(dir, "link"))
                File.symlink?(File.join(dir, "link"))
              end
            rescue NotImplementedError, SystemCallError
              false
            end
        end

        # `destination` is absolute for a machine-wide install and relative for
        # an app one, so expand rather than join — File.join would nest the
        # absolute path under the app root.
        def link_or_copy(canonical, destination)
          target = File.expand_path(File.join(destination, "SKILL.md"), destination_root)
          source = File.expand_path(File.join(canonical, "SKILL.md"), destination_root)
          FileUtils.mkdir_p(File.dirname(target))
          FileUtils.rm_f(target)
          File.symlink(relative_link(source, target), target)
          say_status :symlink, "#{display_path(destination)}/SKILL.md → #{display_path(canonical)}/SKILL.md", :green
        rescue NotImplementedError, SystemCallError => e
          say_status :copy, "#{display_path(destination)}/SKILL.md (symlink unavailable: #{e.class})", :yellow
          copy_file "skills/SKILL.md", File.join(destination, "SKILL.md")
        end

        # Relative so the link survives the repo being cloned elsewhere.
        def relative_link(source, target)
          Pathname.new(source).relative_path_from(Pathname.new(File.dirname(target))).to_s
        end

        # Subtracts the shared ones so the two cleanup questions never cover the
        # same directory — they can overlap when the generator runs in ~.
        def legacy_skill_dirs
          skill_dirs_in(LEGACY_ROOTS.map { File.expand_path(_1, destination_root) }) - shared_legacy_skill_dirs
        end

        def shared_legacy_skill_dirs
          skill_dirs_in([File.expand_path(GLOBAL_LEGACY_ROOT)])
        end

        # A leftover skill directory, or the scripts/ directory an early 4.1.1
        # install left behind. A `rm -rf` driven by a name glob alone is not
        # something to hand a user.
        def skill_dirs_in(roots)
          roots.flat_map { |root| Dir.glob(File.join(root, "avo-*")) + Dir.glob(File.join(root, "avo", "scripts")) }
            .select { |dir| File.directory?(dir) && (File.file?(File.join(dir, "SKILL.md")) || File.basename(dir) == "scripts") }
            .uniq
            .sort
        end

        def removal_command(dirs)
          "rm -rf #{by_directory(dirs).keys.map { "#{_1}avo-*" }.join(" ")}"
        end

        def by_directory(dirs)
          dirs.group_by { display_dir(_1) }.transform_values(&:count).sort.to_h
        end

        def display_dir(path) = "#{display_path(File.dirname(path))}/"

        def pluralize_skills(count) = "#{count} skill#{"s" unless count == 1}"

        def display_path(dir)
          home = File.expand_path("~")
          return dir.sub(home, "~") if dir.start_with?(home) && !dir.start_with?(File.expand_path(destination_root))

          dir.delete_prefix("#{File.expand_path(destination_root)}/")
        end
      end
    end
  end
end
