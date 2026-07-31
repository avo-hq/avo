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

      class_option :only, type: :string, desc: "Install one target only (#{TARGETS.keys.join(", ")})"
      class_option :path, type: :string, desc: "Install to this directory instead of the default scan paths"

      def install_loader
        destinations.each do |destination|
          copy_file "skills/SKILL.md", File.join(destination, "SKILL.md")
          install_resolver File.join(destination, "scripts", "avo-skills-resolve")
        end
      end

      no_tasks do
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
