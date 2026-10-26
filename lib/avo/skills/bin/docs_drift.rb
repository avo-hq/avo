#!/usr/bin/env ruby
# Which docs pages changed since the last indexing run, and which shipped skills
# cite them. The docs repo already hashes every page for us — its git history
# *is* the lock file, so `docs-index.json` only has to remember one commit.
#
# Audits the skills that ship in this gem (the directories beside this bin/).
# Add-on gems carry their own skills and are out of this script's scope.
#
#   ruby lib/avo/skills/bin/docs_drift.rb               # report; finds the docs checkout itself
#   ruby lib/avo/skills/bin/docs_drift.rb path/to/docs  # or point it at one ($AVO_DOCS_PATH works too)
#   ruby lib/avo/skills/bin/docs_drift.rb --update      # mark the checkout's HEAD as indexed
require "json"

skills_root = File.expand_path("..", __dir__)
repo_root = File.expand_path("../../..", skills_root)
marker_path = "#{skills_root}/docs-index.json"
marker = JSON.parse(File.read(marker_path))

update = ARGV.delete("--update")

def git(dir, *args) = `git -C '#{dir}' #{args.join(" ")}`.strip

# A docs checkout is any clone of the marker's repo that has the docs path in it.
# Look next to and above this checkout so the script works from whatever layout a
# machine or CI runner happens to use.
def find_docs(repo_root, marker)
  search = ["#{repo_root}/..", "#{repo_root}/../..", "#{repo_root}/../../.."]
  candidates = search.flat_map { |base| Dir.glob("#{base}/*") }.uniq.sort
  candidates.find do |dir|
    next false if dir == repo_root || !Dir.exist?("#{dir}/.git") || !Dir.exist?("#{dir}/#{marker["docs_path"]}")

    git(dir, "remote", "get-url", "origin").include?(marker["repo"])
  end
end

docs = ARGV[0] || ENV["AVO_DOCS_PATH"] || find_docs(repo_root, marker)

if docs.nil? || !Dir.exist?("#{docs}/.git")
  abort "No #{marker["repo"]} checkout found near #{repo_root} — pass its path as an argument or set AVO_DOCS_PATH."
end

docs = File.expand_path(docs)

head = git(docs, "rev-parse", "HEAD")
head_date = git(docs, "log", "-1", "--format=%cs", "HEAD")

if update
  File.write(marker_path, JSON.pretty_generate(marker.merge("commit" => head, "date" => head_date)) + "\n")
  puts "Indexed at #{head[0, 12]} (#{head_date})."
  exit
end

unless git(docs, "cat-file", "-t", marker["commit"]) == "commit"
  abort "#{docs} doesn't have commit #{marker["commit"]} — `git fetch` it first."
end

if head == marker["commit"]
  puts "Up to date with #{head[0, 12]} (#{head_date})."
  exit
end

# --no-renames: a renamed page is a delete + an add, which is exactly how a skill
# citing the old URL has to treat it.
changed = git(docs, "diff", "--name-status", "--no-renames", "#{marker["commit"]}..HEAD", "--", marker["docs_path"])
  .lines.map { |line| line.split("\t") }
  .map { |status, path| [status[0], File.basename(path.strip)] }
  .reject { |_, page| page == "docs-map.md" }
  .uniq

# The Docs lines in each SKILL.md are the provenance record. Skills cite pages
# both with and without the .md extension; normalize to the diff's basename form.
version = Regexp.escape(File.basename(marker["docs_path"]))
citations = Dir.glob("#{skills_root}/*/SKILL.md").each_with_object(Hash.new { |h, k| h[k] = [] }) do |path, acc|
  skill = File.basename(File.dirname(path))
  # Read as UTF-8 explicitly: skills are full of em dashes and non-English
  # examples, and under a C/POSIX locale File.read would tag them US-ASCII and
  # blow up on the first scan.
  File.read(path, encoding: "UTF-8").scan(%r{docs\.avohq\.io/#{version}/([A-Za-z0-9_/-]+)}).flatten.uniq.each do |page|
    acc["#{File.basename(page)}.md"] << skill
  end
end

puts "#{changed.size} pages changed between #{marker["commit"][0, 12]} (#{marker["date"]}) and #{head[0, 12]} (#{head_date}):", ""

stale = []
changed.sort_by(&:last).each do |status, page|
  skills = citations[page]
  stale.concat(skills)
  puts "  #{status} #{page.ljust(34)} #{skills.empty? ? "— not cited by any skill" : skills.join(", ")}"
end

puts "", "Skills to review: #{stale.uniq.sort.join(", ")}" if stale.any?
puts "", "Commits: git -C #{docs} log --oneline #{marker["commit"][0, 12]}..HEAD -- #{marker["docs_path"]}"
puts "Then:    ruby lib/avo/skills/bin/docs_drift.rb --update"
