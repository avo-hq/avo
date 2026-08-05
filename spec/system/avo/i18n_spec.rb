# frozen_string_literal: true

require "i18n/tasks"

RSpec.describe I18n do
  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys }
  let(:unused_keys) { i18n.unused_keys }
  let(:inconsistent_interpolations) { i18n.inconsistent_interpolations }

  # Using i18n tags in these tests, so we can exclude them
  # when running system_tests in CI and run only these tests in
  # a separate job.
  it "does not have missing keys", i18n: true do
    expect(missing_keys).to be_empty,
      "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing' to show them"
  end

  # it 'does not have unused keys' do
  #   expect(unused_keys).to be_empty,
  #                          "#{unused_keys.leaves.count} unused i18n keys, run `i18n-tasks unused' to show them"
  # end

  it "files are normalized", i18n: true do
    non_normalized = i18n.non_normalized_paths
    error_message = "The following files need to be normalized:\n" \
                    "#{non_normalized.map { |path| "  #{path}" }.join("\n")}\n" \
                    "Please run `i18n-tasks normalize' to fix"
    expect(non_normalized).to be_empty, error_message
  end

  it "does not have inconsistent interpolations", i18n: true do
    error_message = "#{inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations.\n" \
                    "Run `i18n-tasks check-consistent-interpolations' to show them"
    expect(inconsistent_interpolations).to be_empty, error_message
  end
end
