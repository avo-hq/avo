#!/usr/bin/env ruby
# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'

puts('Merging coverage results...')

report_path = ARGV[0] || 'coverage.lcov'
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config.single_report_path = report_path

SimpleCov.collate(['coverage_features/.resultset.json', 'coverage_system/.resultset.json']) do
  enable_coverage :branch
  formatter SimpleCov::Formatter::LcovFormatter
end

if File.size(report_path).zero?
  puts('Written report has 0 bytes')
  exit 1
end
puts("Done! LCOV saved to #{SimpleCov::Formatter::LcovFormatter.config.single_report_path}")
