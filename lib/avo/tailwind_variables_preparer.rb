require "fileutils"
require "rubygems"

module Avo
  class TailwindVariablesPreparer
    def self.prepare(target:, label:, avo_gem_path: nil, cwd: Dir.pwd)
      source = resolve_source(avo_gem_path:, cwd:)
      unless source
        raise "[#{label}] Could not resolve Avo variables.css source."
      end

      target_dir = File.dirname(target)
      begin
        FileUtils.mkdir_p(target_dir)
      rescue Errno::EACCES
        warn "[#{label}] prebuild_css: cannot create #{target_dir} (permission denied). Skipping."
        return true
      end

      if File.exist?(target) || File.symlink?(target)
        begin
          return true if File.identical?(source, target)
        rescue
          # ignore and continue
        end

        begin
          File.delete(target)
        rescue Errno::EACCES
          warn "[#{label}] prebuild_css: cannot update #{target} (permission denied). Skipping."
          return true
        end
      end

      begin
        File.symlink(source, target)
      rescue Errno::EEXIST
        begin
          return true if File.identical?(source, target)
          File.delete(target)
          File.symlink(source, target)
        rescue
          copy_unless_identical(source, target)
        end
      rescue
        copy_unless_identical(source, target)
      end

      true
    end

    def self.resolve_source(avo_gem_path: nil, cwd: Dir.pwd)
      roots = []
      roots << avo_gem_path if avo_gem_path
      roots << File.expand_path("../avo", cwd)
      roots << `bundle show avo 2>/dev/null`.strip

      begin
        roots << Gem::Specification.find_by_name("avo").full_gem_path
      rescue Gem::LoadError
        # ignore
      end

      roots
        .compact
        .map(&:strip)
        .reject(&:empty?)
        .uniq
        .map { |root| File.join(root, "app/assets/stylesheets/css/variables.css") }
        .find { |path| File.exist?(path) }
    end

    def self.copy_unless_identical(source, target)
      return if File.exist?(target) && File.identical?(source, target)

      FileUtils.cp(source, target)
    end
  end
end
