# frozen_string_literal: true

# =============================================================================
# RTL TAILWIND CLASS ENFORCEMENT
# =============================================================================
# This Dangerfile ensures that directional Tailwind CSS classes are replaced
# with their logical equivalents for proper RTL (Right-to-Left) support.
#
# Run locally with: bundle exec danger local
# Run in CI with: bundle exec danger
# =============================================================================

# Define violations as [physical, logical, label (optional)]
RTL_RULES = [
  # Padding
  ["pl", "ps", "padding-start"],
  ["pr", "pe", "padding-end"],
  # Margin
  ["ml", "ms", "margin-start"],
  ["mr", "me", "margin-end"],
  # Positioning
  ["left", "start"],
  ["right", "end"],
  # Borders
  ["border-l", "border-s"],
  ["border-r", "border-e"],
  # Rounded corners
  ["rounded-l", "rounded-s"],
  ["rounded-r", "rounded-e"],
  ["rounded-tl", "rounded-ss", "start-start"],
  ["rounded-tr", "rounded-se", "start-end"],
  ["rounded-bl", "rounded-es", "end-start"],
  ["rounded-br", "rounded-ee", "end-end"],
  # Text alignment
  ["text-left", "text-start"],
  ["text-right", "text-end"],
  # Scroll
  ["scroll-pl", "scroll-ps"],
  ["scroll-pr", "scroll-pe"],
  ["scroll-ml", "scroll-ms"],
  ["scroll-mr", "scroll-me"]
].freeze

# Generate violations hash from rules
RTL_CLASS_VIOLATIONS = RTL_RULES.to_h do |physical, logical, label|
  pattern = case physical
  when /^(pl|pr|ml|mr)$/
    /\b#{physical}-(\d+|px|auto)/
  when /^(left|right)$/
    /\b#{physical}-(\d+|px|auto|full|\[.*?\])/
  when /^text-/
    /\b#{physical}\b/
  when /^scroll-/
    /\b#{physical}-/
  else
    /\b#{physical}(?:-\w+)?(?!\w)/
  end

  label_text = label ? " (#{label})" : ""
  description = "Use `#{logical}-*`#{label_text} instead of `#{physical}-*`"

  [pattern, {replacement: "#{logical}-", description: description}]
end.freeze

def check_rtl_compliance(file_path, file_content)
  violations = []
  lines = file_content.split("\n")

  lines.each_with_index do |line, index|
    line_number = index + 1

    # Skip lines with RTL/LTR variants (already handled)
    next if line.match?(/rtl:|ltr:/)

    # Check for direct violations
    RTL_CLASS_VIOLATIONS.each do |pattern, info|
      next unless line.match?(pattern)

      violations << {
        file: file_path,
        line: line_number,
        message: info[:description],
        matched: line.strip[0..100],
        replacement: info[:replacement]
      }
    end

    # Check for space-x without rtl:space-x-reverse companion
    if line.match?(/\bspace-x-\d+/) && !line.match?(/rtl:space-x-reverse/)
      # Only warn if this looks like a class attribute (not in CSS/JS logic)
      if line.match?(/class[=:]|className/) || file_path.end_with?(".erb")
        violations << {
          file: file_path,
          line: line_number,
          message: "Consider adding `rtl:space-x-reverse` when using `space-x-*` for proper RTL spacing",
          matched: line.strip[0..100],
          replacement: "rtl:space-x-reverse",
          severity: :warning
        }
      end
    end
  end

  violations
end

# =============================================================================
# DANGER CHECKS
# =============================================================================

# Collect ALL files (erb, rb, js, css), excluding generated/vendor directories
all_repo_files = Dir.glob("**/*.{erb,rb,js,css}").select do |f|
  File.file?(f) &&
    !f.start_with?("node_modules/", "vendor/", "tmp/") &&
    !f.include?("/node_modules/") &&
    !f.include?("/vendor/") &&
    !f.include?("/tmp/") &&
    !f.include?("/builds/")
end

all_violations = []

all_repo_files.each do |file|
  content = File.read(file)
  violations = check_rtl_compliance(file, content)
  all_violations.concat(violations)
end

# Only report if there are violations
if all_violations.any?
  errors = all_violations.reject { |v| v[:severity] == :warning }
  warnings = all_violations.select { |v| v[:severity] == :warning }

  # Report errors (will fail CI)
  errors.each do |violation|
    fail("`#{violation[:file]}:#{violation[:line]}` #{violation[:message]}\n" \
         "```\n#{violation[:matched]}\n```")
  end

  # Report warnings
  warnings.each do |violation|
    warn("`#{violation[:file]}:#{violation[:line]}` #{violation[:message]}\n" \
         "```\n#{violation[:matched]}\n```")
  end
end

# =============================================================================
# GENERAL PR CHECKS
# =============================================================================

# Get changed files for PR-specific checks
changed_files = (git.modified_files + git.added_files).uniq

# Warn if PR is too large
warn("This PR is quite large. Consider breaking it into smaller PRs for easier review.") if git.lines_of_code > 900

# Encourage adding tests for new features
has_app_changes = changed_files.any? { |f| f.start_with?("app/", "lib/") }
has_test_changes = changed_files.any? { |f| f.start_with?("spec/") }

if has_app_changes && !has_test_changes
  warn("This PR has code changes but no test changes. Consider adding tests.")
end
