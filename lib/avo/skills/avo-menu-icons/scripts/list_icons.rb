#!/usr/bin/env ruby
# frozen_string_literal: true

# Lists every Tabler icon name Avo can render, grouped by style.
#
# The icons ship inside the `avo-icons` gem, which is a hard dependency of `avo`,
# so this reads them off disk — no network call, no GitHub rate limit, and no
# cache file. That matters here: this script lives inside an installed gem, and
# gem directories are frequently read-only, so writing a cache next to it would
# fail on exactly the machines it needs to work on.
#
# Usage:
#   ruby list_icons.rb            # both styles
#   ruby list_icons.rb outline    # one style
#   ruby list_icons.rb --count    # just the totals

require "rubygems"

STYLES = %w[outline filled].freeze

def icons_root
  spec = Gem::Specification.find_all_by_name("avo-icons").max_by(&:version)
  abort "avo-icons gem not found. It is a dependency of avo — run `bundle install`." if spec.nil?

  root = File.join(spec.gem_dir, "lib", "assets", "svgs", "tabler")
  abort "avo-icons #{spec.version} has no tabler icons at #{root}" unless Dir.exist?(root)

  root
end

def names_for(root, style)
  Dir.glob(File.join(root, style, "*.svg")).map { |p| File.basename(p, ".svg") }.sort
end

args = ARGV.dup
count_only = args.delete("--count")
styles = args.empty? ? STYLES : (args & STYLES)
abort "unknown style. Valid styles: #{STYLES.join(", ")}" if styles.empty?

root = icons_root

styles.each do |style|
  names = names_for(root, style)
  if count_only
    puts "#{style}: #{names.size}"
  else
    puts "#{style}: #{names.join(", ")}"
  end
end
