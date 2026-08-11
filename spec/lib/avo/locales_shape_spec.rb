# frozen_string_literal: true

require "rails_helper"

# The shape contract for the locale files Avo itself ships (AVO-1464).
#
# I18n deep-merges every file on `I18n.load_path` into one tree per locale, and a
# String and a Hash cannot merge at the same path — whichever loads last replaces
# the other, with no warning and no error. `avo.dashboards` is the live example: it
# is the sidebar's section heading, and an `avo.dashboards.my_dash.name` key nested
# beneath it deletes that heading. Core owns 125 strings and 12 hashes directly
# under `avo.`, and nothing else stops a contributor turning one of those strings
# into a hash — the change that silently breaks every app overriding it.
#
# Everything here compares shapes **per locale**. `en.avo.applied` and
# `es.avo.applied` are different I18n subtrees that never merge with each other, so
# a String in one and a Hash in the other is not a collision — it is two languages.
# A cross-file comparison is red on 13 of the 19 files against correct data.
#
# If one of these fails, the locale file is wrong. Do not "fix" it by relaxing the
# expectation.
module AvoLocaleShape
  # CLDR's plural categories, and the only keys allowed to appear at a path
  # `avo.en.yml` does not have. Languages legitimately carry categories English
  # lacks: pl/ru/ua add `few` and `many`, `ar` adds `few`/`many`/`two`/`zero`, `ro`
  # adds `few` — 56 such keys across 13 files today.
  PLURAL_CATEGORIES = %w[zero one two few many other].freeze

  # The roots Avo derives a key for but ships no value under. They belong to the
  # app, and a core key there would shadow the app's own translation.
  #
  #   avo.resource_translations.*   lib/avo/resources/base.rb
  #   avo.action_translations.*     lib/avo/base_action.rb
  #   avo.field_translations.*      lib/avo/fields/base_field.rb
  #   avo.scope_translations.*      avo-scopes
  #   avo.card_translations.*       avo-dashboards
  #   avo.dashboard_translations.*  avo-dashboards
  #
  # Matched by suffix rather than against that list, so a seventh root is covered
  # the day it is derived instead of the day someone remembers to add it here.
  TRANSLATIONS_ROOT = /\Aavo\.\w+_translations(\.|\z)/

  # `avo.applied` is a plain String in en/de/it/nl/pl/ru/ua/zh/zh-TW and a
  # pluralization Hash in ar/es/fr/ja/nb/nn/pt/pt-BR/ro/tr. It is also dead — zero
  # call sites anywhere in `app/` or `lib/` — so it is exempted here rather than
  # made consistent: flattening the ten plural Hashes would change lookup, and
  # removing the key is core cleanup for its own ticket. When that ticket lands,
  # "still needs its exemption" below goes red and tells you to delete this.
  SHAPE_EXEMPT_PATHS = %w[avo.applied].freeze

  # Flattens a parsed locale body into {"avo.save" => :leaf, "avo.file" => :hash,
  # "avo.file.one" => :leaf, …}. A leaf is anything I18n hands back as a value; a
  # hash is anything it descends into, which is the only distinction that decides
  # whether two trees can merge.
  def self.flatten(node, prefix = nil, into = {})
    node.each do |key, value|
      path = prefix ? "#{prefix}.#{key}" : key.to_s

      if value.is_a?(Hash)
        into[path] = :hash
        flatten(value, path, into)
      else
        into[path] = :leaf
      end
    end

    into
  end

  # Paths one locale holds as a leaf in one file and a hash in another. Takes
  # {file_label => shape} for a **single** locale, which is the only grouping that
  # matches runtime.
  def self.collisions(shapes_by_file)
    shapes_by_file.values.flat_map(&:keys).uniq.filter_map do |path|
      holders = shapes_by_file.filter_map { |label, shape| [label, shape[path]] if shape.key?(path) }
      next if holders.map(&:last).uniq.size < 2

      "#{path} — #{holders.map { |label, type| "#{type} in #{label}" }.join(", ")}"
    end
  end

  # Keys shipped under a root reserved for the app.
  def self.reserved_root_keys(shape)
    shape.keys.grep(TRANSLATIONS_ROOT)
  end

  # How +subject+'s shape differs from +reference+'s. A key the subject simply does
  # not translate is not a divergence — an untranslated key is normal, and falls
  # back. What is a divergence: reshaping a path the reference already has, or
  # adding a path the reference lacks, unless that path is a plural category.
  def self.divergences(reference:, subject:, exempt: SHAPE_EXEMPT_PATHS)
    subject.filter_map do |path, type|
      next if exempt.any? { |prefix| path == prefix || path.start_with?("#{prefix}.") }

      if !reference.key?(path)
        next if PLURAL_CATEGORIES.include?(path.split(".").last)

        "#{path} — added, and #{path.split(".").last.inspect} is not a CLDR plural category"
      elsif reference[path] != type
        "#{path} — #{reference[path]} in the reference, #{type} here"
      end
    end
  end
end

RSpec.describe "Avo's shipped locale files" do
  # Mirrors the glob at lib/avo/engine.rb:178 exactly, non-recursion included. The
  # pagy locales in the subdirectory load through `Pagy::I18n.pathnames`
  # (config/initializers/pagy.rb:4), sit outside the `avo.*` tree, and are never on
  # `I18n.load_path` — recursing here would scan files Avo does not merge.
  let(:locales_dir) { Avo::Engine.root.join("lib", "generators", "avo", "templates", "locales") }
  let(:locale_paths) { Dir[locales_dir.join("*.{rb,yml}")].sort }

  # Keyed by basename, so every failure below names the file a maintainer opens.
  let(:locale_files) do
    locale_paths.map do |path|
      document = YAML.load_file(path)
      locale = document.keys.first

      {name: File.basename(path), locale: locale, shape: AvoLocaleShape.flatten(document.fetch(locale))}
    end
  end

  let(:reference) { locale_files.find { |file| file[:locale] == "en" }.fetch(:shape) }

  describe "the scan itself" do
    # Without this the three invariants could pass while scanning nothing, or while
    # scanning files the engine never merges.
    it "scans exactly the files the engine puts on I18n.load_path" do
      # Deduplicated because the boot path enters each file twice; I18n merges a
      # repeated entry into the same tree, so the set is what matters here.
      loaded = I18n.load_path.map(&:to_s).select { |path| path.start_with?("#{locales_dir}/") }.uniq

      expect(locale_paths).to eq(loaded.sort)
      expect(locale_paths).not_to be_empty
    end

    it "leaves the pagy locales out of the scan" do
      pagy_paths = Dir[locales_dir.join("pagy", "*.yml")]

      # Guards the guard: the exclusion means nothing once these files are gone.
      expect(pagy_paths).not_to be_empty
      expect(locale_paths).not_to include(*pagy_paths)
    end

    it "reads every scanned file as YAML rooted at a single locale" do
      offenders = locale_paths.reject { |path| path.end_with?(".yml") }

      expect(offenders).to be_empty, lambda {
        "The engine merges every *.{rb,yml} in this directory, but this scan only " \
          "reads YAML. Teach it the other format before shipping:\n  #{offenders.join("\n  ")}"
      }
      expect(locale_files.map { |file| file[:locale] }).to eq(locale_files.map { |file| file[:locale] }.uniq)
    end
  end

  # The only comparison that matches runtime. Core ships one file per locale today,
  # so this passes trivially on the real tree — it is here for the day a second file
  # appears for one locale, and the fixtures below are what prove it can fail.
  describe "invariant 1: within one locale, no path is both a String and a Hash" do
    it "holds no path as both in any locale core ships" do
      offenders = locale_files.group_by { |file| file[:locale] }.flat_map do |locale, files|
        shapes = files.to_h { |file| [file[:name], file[:shape]] }

        AvoLocaleShape.collisions(shapes).map { |collision| "  #{locale}: #{collision}" }
      end

      expect(offenders).to be_empty, lambda {
        "A String and a Hash cannot merge at one path — whichever file loads last " \
          "replaces the other silently:\n#{offenders.join("\n")}"
      }
    end

    it "names the path and both files when a locale nests beneath its own string" do
      shapes = {
        "avo.en.yml" => AvoLocaleShape.flatten({"avo" => {"foo" => "Foo"}}),
        "avo.extra.en.yml" => AvoLocaleShape.flatten({"avo" => {"foo" => {"bar" => "Bar"}}})
      }

      collisions = AvoLocaleShape.collisions(shapes)

      expect(collisions).to contain_exactly(
        "avo.foo — leaf in avo.en.yml, hash in avo.extra.en.yml"
      )
    end

    it "reports nothing when both files agree on a path's shape" do
      shapes = {
        "avo.en.yml" => AvoLocaleShape.flatten({"avo" => {"foo" => "Foo"}}),
        "avo.extra.en.yml" => AvoLocaleShape.flatten({"avo" => {"foo" => "Overridden"}})
      }

      expect(AvoLocaleShape.collisions(shapes)).to be_empty
    end
  end

  describe "invariant 2: core ships no key under a *_translations root" do
    it "leaves every extensible root empty" do
      offenders = locale_files.flat_map do |file|
        AvoLocaleShape.reserved_root_keys(file[:shape]).map { |path| "  #{path} in #{file[:name]}" }
      end

      expect(offenders).to be_empty, lambda {
        "These roots are the app's to fill — Avo derives the key and the app " \
          "supplies the value. A core key here shadows the app's own " \
          "translation:\n#{offenders.join("\n")}"
      }
    end

    it "names the root when core ships one" do
      shape = AvoLocaleShape.flatten({"avo" => {"field_translations" => {"user" => {"name" => "Name"}}}})

      expect(AvoLocaleShape.reserved_root_keys(shape)).to contain_exactly(
        "avo.field_translations",
        "avo.field_translations.user",
        "avo.field_translations.user.name"
      )
    end

    it "does not mistake an ordinary namespace for a reserved root" do
      shape = AvoLocaleShape.flatten({"avo" => {"translations_count" => "1", "global_search" => {"all" => "All"}}})

      expect(AvoLocaleShape.reserved_root_keys(shape)).to be_empty
    end
  end

  describe "invariant 3: divergence from avo.en.yml is plural categories only" do
    it "restructures no namespace in any translated locale" do
      offenders = locale_files.reject { |file| file[:locale] == "en" }.flat_map do |file|
        AvoLocaleShape.divergences(reference: reference, subject: file[:shape])
          .map { |divergence| "  #{file[:name]}: #{divergence}" }
      end

      expect(offenders).to be_empty, lambda {
        "A translated locale may add CLDR plural categories and may leave keys " \
          "untranslated. It may not reshape a namespace — apps override these " \
          "paths, and the shape is what they override against. Measured against " \
          "avo.en.yml:\n#{offenders.join("\n")}"
      }
    end

    # The plural allowance is the reason this invariant is not a plain shape diff,
    # so it has to be exercised by real data rather than by fixtures alone.
    it "is carrying real plural categories English does not have" do
      additions = locale_files.reject { |file| file[:locale] == "en" }.flat_map do |file|
        file[:shape].keys.reject { |path| reference.key?(path) }
      end

      expect(additions).not_to be_empty
      expect(additions.map { |path| path.split(".").last }.uniq)
        .to all(be_in(AvoLocaleShape::PLURAL_CATEGORIES))
    end

    # Deliberately fails when `avo.applied` is finally removed or made consistent,
    # so the exemption cannot outlive the key it excuses.
    it "still needs its avo.applied exemption" do
      unexempted = locale_files.reject { |file| file[:locale] == "en" }.flat_map do |file|
        AvoLocaleShape.divergences(reference: reference, subject: file[:shape], exempt: [])
      end

      expect(unexempted).not_to be_empty, "avo.applied is consistent now — delete " \
        "AvoLocaleShape::SHAPE_EXEMPT_PATHS and this example"
      expect(unexempted.map { |divergence| divergence.split(" — ").first }.uniq).to eq(%w[avo.applied])
    end

    it "names the path when a locale adds a non-plural child under a hash" do
      reference = AvoLocaleShape.flatten({"avo" => {"record" => {"one" => "record", "other" => "records"}}})
      subject = AvoLocaleShape.flatten({"avo" => {"record" => {"one" => "înregistrare", "custom" => "nope"}}})

      expect(AvoLocaleShape.divergences(reference: reference, subject: subject)).to contain_exactly(
        %(avo.record.custom — added, and "custom" is not a CLDR plural category)
      )
    end

    it "names the path when a locale flattens a hash into a string" do
      reference = AvoLocaleShape.flatten({"avo" => {"record" => {"one" => "record", "other" => "records"}}})
      subject = AvoLocaleShape.flatten({"avo" => {"record" => "Datensatz"}})

      expect(AvoLocaleShape.divergences(reference: reference, subject: subject)).to contain_exactly(
        "avo.record — hash in the reference, leaf here"
      )
    end

    it "names the path when a locale nests beneath a string" do
      reference = AvoLocaleShape.flatten({"avo" => {"dashboards" => "Dashboards"}})
      subject = AvoLocaleShape.flatten({"avo" => {"dashboards" => {"my_dash" => {"name" => "Mijn dashboard"}}}})

      expect(AvoLocaleShape.divergences(reference: reference, subject: subject)).to include(
        "avo.dashboards — leaf in the reference, hash here"
      )
    end

    it "accepts the few/many forms pl, ru and ua add" do
      reference = AvoLocaleShape.flatten({"avo" => {"file" => {"one" => "file", "other" => "files"}}})
      subject = AvoLocaleShape.flatten(
        {"avo" => {"file" => {"one" => "plik", "few" => "pliki", "many" => "plików", "other" => "pliku"}}}
      )

      expect(AvoLocaleShape.divergences(reference: reference, subject: subject)).to be_empty
    end

    it "accepts the two/zero forms ar adds" do
      reference = AvoLocaleShape.flatten({"avo" => {"record" => {"one" => "record", "other" => "records"}}})
      subject = AvoLocaleShape.flatten(
        {"avo" => {"record" => {"zero" => "لا سجلات", "one" => "سجل", "two" => "سجلان", "other" => "سجلات"}}}
      )

      expect(AvoLocaleShape.divergences(reference: reference, subject: subject)).to be_empty
    end

    it "accepts a locale that leaves keys untranslated" do
      reference = AvoLocaleShape.flatten({"avo" => {"save" => "Save", "appearance" => {"dark" => "Dark"}}})
      subject = AvoLocaleShape.flatten({"avo" => {"save" => "Salvar"}})

      expect(AvoLocaleShape.divergences(reference: reference, subject: subject)).to be_empty
    end

    it "accepts an override that keeps the shape" do
      reference = AvoLocaleShape.flatten({"avo" => {"dashboards" => "Dashboards"}})
      subject = AvoLocaleShape.flatten({"avo" => {"dashboards" => "Tableaux de bord"}})

      expect(AvoLocaleShape.divergences(reference: reference, subject: subject)).to be_empty
    end
  end
end
