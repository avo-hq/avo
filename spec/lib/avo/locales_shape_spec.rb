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

  # The only namespace core's locale files may open under a locale. A stray root
  # here is not a near miss — `en.date.formats.default` reaches every `l()` call in
  # the host app, which is a wider blast radius than the collision this file was
  # written for.
  NAMESPACE = "avo"

  # `avo.applied` is a plain String in en/de/it/nl/pl/ru/ua/zh/zh-TW and a
  # pluralization Hash in ar/es/fr/ja/nb/nn/pt/pt-BR/ro/tr. It is also dead — zero
  # call sites anywhere in `app/` or `lib/` — so it is exempted here rather than
  # made consistent: flattening the ten plural Hashes would change lookup, and
  # removing the key is core cleanup for its own ticket. When that ticket lands,
  # "still needs its exemption" below goes red and tells you to delete this.
  SHAPE_EXEMPT_PATHS = %w[avo.applied].freeze

  # The checked-in shape of `avo.en.yml`. Every comparison below measures the other
  # eighteen files against en, so nothing in the scan itself pins what en's own
  # shape is: a string→hash flip applied uniformly to all nineteen files moves the
  # reference along with its subjects and passes green. This file is the fixed
  # point that flip has to survive, and it cannot — the diff lands in review.
  EN_SHAPE_FIXTURE = Avo::Engine.root.join("spec", "fixtures", "locales", "en_shape.txt")

  # The command that rewrites the fixture, quoted verbatim in the failure message
  # so a maintainer never has to guess at it.
  REGENERATE_COMMAND = "REGENERATE_EN_SHAPE=1 bundle exec rspec spec/lib/avo/locales_shape_spec.rb"

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

  # One sorted `<path> <leaf|hash>` line per entry. Deliberately line-oriented and
  # sorted: the fixture is read by whoever reviews the diff, and a reshaped key has
  # to show up as one line changing rather than as a reordered blob.
  def self.serialize(shape)
    shape.sort.map { |path, type| "#{path} #{type}\n" }.join
  end

  def self.deserialize(text)
    text.each_line.filter_map do |line|
      path, type = line.split

      [path, type.to_sym] if path
    end.to_h
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

  def self.exempt?(path, exempt)
    exempt.any? { |prefix| path == prefix || path.start_with?("#{prefix}.") }
  end

  # Whether a locale is allowed to carry +path+ at a path the reference lacks. Both
  # halves matter. The **name** has to be a CLDR plural category, and the node has
  # to be a **leaf**: `avo.file.few` holding a hash is malformed pluralization data,
  # and an `avo.other` hash is a whole subtree the reference has no trace of. A
  # name-only test waves both through.
  def self.plural_addition?(path, type)
    type == :leaf && PLURAL_CATEGORIES.include?(path.split(".").last)
  end

  # The paths +subject+ carries that +reference+ does not, minus the plural
  # categories a language legitimately adds. Split out from `divergences` because
  # the same set answers a second question — see `orphaned_from_reference`.
  def self.added_paths(reference:, subject:, exempt: SHAPE_EXEMPT_PATHS)
    subject.filter_map do |path, type|
      next if exempt?(path, exempt)
      next if reference.key?(path)
      next if plural_addition?(path, type)

      path
    end
  end

  # Paths *every* translated locale adds. Eighteen files do not independently grow
  # the same key; the reference lost it. Reported apart from the additions below
  # because the two ask for opposite fixes — an addition is deleted from the one
  # locale that has it, an orphan is restored to `avo.en.yml`.
  def self.orphaned_from_reference(reference:, subjects:, exempt: SHAPE_EXEMPT_PATHS)
    return [] if subjects.empty?

    subjects.map { |shape| added_paths(reference: reference, subject: shape, exempt: exempt) }.reduce(:&).sort
  end

  # How +subject+'s shape differs from +reference+'s. A key the subject simply does
  # not translate is not a divergence — an untranslated key is normal, and falls
  # back. What is a divergence: reshaping a path the reference already has, or
  # adding a path the reference lacks, unless that path is a plural category.
  #
  # +ignore+ carries the orphans, which are reported by their own wording rather
  # than as additions.
  def self.divergences(reference:, subject:, exempt: SHAPE_EXEMPT_PATHS, ignore: [])
    subject.filter_map do |path, type|
      next if exempt?(path, exempt)
      next if ignore.include?(path)

      if !reference.key?(path)
        next if plural_addition?(path, type)

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
  # `roots` is carried rather than discarded: `document.fetch(locale)` reads one
  # subtree, and a second root in the same file would otherwise be invisible to
  # every invariant here.
  let(:locale_files) do
    locale_paths.map do |path|
      document = YAML.load_file(path)
      locale = document.keys.first
      body = document.fetch(locale)

      {
        name: File.basename(path),
        locale: locale,
        roots: document.keys,
        namespaces: body.keys.map(&:to_s),
        shape: AvoLocaleShape.flatten(body)
      }
    end
  end

  let(:reference) { locale_files.find { |file| file[:locale] == "en" }.fetch(:shape) }
  let(:translated) { locale_files.reject { |file| file[:locale] == "en" } }

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

      # Not cosmetics. Only the first root is read below, so a second one ships
      # unscanned — no collision check, no reserved-root check, no shape check.
      multi_rooted = locale_files.reject { |file| file[:roots].size == 1 }.map do |file|
        "  #{file[:name]}: #{file[:roots].join(", ")}"
      end

      expect(multi_rooted).to be_empty, lambda {
        "A locale file opens one locale. Every root after the first is invisible " \
          "to every invariant below — split the file rather than teaching this " \
          "scan to squint:\n#{multi_rooted.join("\n")}"
      }
    end

    it "opens nothing but the avo namespace under its locale" do
      offenders = locale_files.flat_map do |file|
        (file[:namespaces] - [AvoLocaleShape::NAMESPACE]).map { |root| "  #{file[:name]}: #{file[:locale]}.#{root}" }
      end

      expect(offenders).to be_empty, lambda {
        "Core's locale files own the `avo.` namespace and nothing else. A root " \
          "outside it merges straight into the host app's own translations — " \
          "`date.formats.default` alone rewrites every `l()` call in the app:\n" \
          "#{offenders.join("\n")}"
      }
    end
  end

  # The only comparison that matches runtime. Core ships one file per locale today,
  # so this passes trivially on the real tree — it is here for the day a second file
  # appears for one locale, and the fixtures below are what prove it can fail. That
  # day is a supported input, not a scan error, which is why nothing above asserts
  # one file per locale.
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

  # Everything in invariant 3 is measured *against* en, so en's own shape is the one
  # thing it cannot see. Pinning it to a checked-in file is what stops a sweep that
  # reshapes all nineteen locales at once from passing green.
  describe "invariant 3a: avo.en.yml holds the shape checked in beside this spec" do
    it "matches spec/fixtures/locales/en_shape.txt at every depth" do
      # Regeneration lives inside the example so the fixture can only ever be
      # written by the same code that reads it. A separate script would be free to
      # drift from this format, and a fixture that no longer parses is a guard that
      # silently stops guarding.
      if ENV["REGENERATE_EN_SHAPE"]
        File.write(AvoLocaleShape::EN_SHAPE_FIXTURE, AvoLocaleShape.serialize(reference))

        skip "rewrote #{AvoLocaleShape::EN_SHAPE_FIXTURE} — read the diff before committing it"
      end

      recorded = AvoLocaleShape.deserialize(File.read(AvoLocaleShape::EN_SHAPE_FIXTURE))

      reshaped = (recorded.keys & reference.keys).sort.filter_map do |path|
        "  #{path} — #{recorded[path]} in the fixture, #{reference[path]} in avo.en.yml" if recorded[path] != reference[path]
      end
      added = (reference.keys - recorded.keys).sort.map { |path| "  #{path} — #{reference[path]}, not in the fixture" }
      removed = (recorded.keys - reference.keys).sort.map { |path| "  #{path} — #{recorded[path]} in the fixture, gone from avo.en.yml" }

      expect(reshaped + added + removed).to be_empty, lambda {
        "avo.en.yml no longer has the shape recorded in " \
          "spec/fixtures/locales/en_shape.txt.\n\n" \
          "#{(reshaped + added + removed).join("\n")}\n\n" \
          "A `reshaped` line is the dangerous one: it is a String↔Hash flip in the " \
          "reference every other locale is measured against, and applying the same " \
          "flip to all nineteen files hides it from every other example here. If " \
          "that is what you meant to do, regenerate the fixture so the flip lands " \
          "in review as a diff someone signs off on:\n\n" \
          "  #{AvoLocaleShape::REGENERATE_COMMAND}\n\n" \
          "If it is not, avo.en.yml is wrong. Do not regenerate to make this pass."
      }
    end
  end

  describe "invariant 3: divergence from avo.en.yml is plural categories only" do
    it "restructures no namespace in any translated locale" do
      orphans = AvoLocaleShape.orphaned_from_reference(reference: reference, subjects: translated.map { |file| file[:shape] })

      offenders = translated.flat_map do |file|
        AvoLocaleShape.divergences(reference: reference, subject: file[:shape], ignore: orphans)
          .map { |divergence| "  #{file[:name]}: #{divergence}" }
      end

      # Reported apart from the additions above, and worded the other way round:
      # nothing was added to eighteen files at once, so the key was removed from the
      # reference. Told as an addition, the shortest path back to green is deleting
      # it from eighteen translations — the opposite of the fix.
      orphaned = orphans.map do |path|
        "  #{path} — present in all #{translated.size} translated locales, " \
          "missing from avo.en.yml (removed from the reference?)"
      end

      expect(offenders + orphaned).to be_empty, lambda {
        "A translated locale may add CLDR plural categories and may leave keys " \
          "untranslated. It may not reshape a namespace — apps override these " \
          "paths, and the shape is what they override against. Measured against " \
          "avo.en.yml:\n#{(offenders + orphaned).join("\n")}"
      }
    end

    # The plural allowance is the reason this invariant is not a plain shape diff,
    # so it has to be exercised by real data rather than by fixtures alone.
    it "is carrying real plural categories English does not have" do
      additions = translated.flat_map do |file|
        file[:shape].reject { |path, _type| reference.key?(path) }.to_a
      end

      expect(additions).not_to be_empty
      expect(additions.map { |path, _type| path.split(".").last }.uniq)
        .to all(be_in(AvoLocaleShape::PLURAL_CATEGORIES))
      # The allowance only covers leaves. If a real plural addition is ever a Hash,
      # the allowance stops covering it and this says so before the invariant does.
      expect(additions.map { |_path, type| type }.uniq).to eq([:leaf])
    end

    # Deliberately fails when `avo.applied` is finally removed or made consistent,
    # so the exemption cannot outlive the key it excuses.
    it "still needs its avo.applied exemption" do
      unexempted = translated.flat_map do |file|
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

    it "names the path when a locale adds a whole subtree named for a plural category" do
      reference = AvoLocaleShape.flatten({"avo" => {"save" => "Save"}})
      subject = AvoLocaleShape.flatten({"avo" => {"other" => {"one" => "unul", "other" => "altele"}}})

      # `avo.other` is a hash, so the plural allowance does not reach it — it is a
      # namespace the reference has no trace of, wearing a plural category's name.
      expect(AvoLocaleShape.divergences(reference: reference, subject: subject)).to include(
        %(avo.other — added, and "other" is not a CLDR plural category)
      )
    end

    it "names the path when a plural category holds a hash instead of a string" do
      reference = AvoLocaleShape.flatten({"avo" => {"file" => {"one" => "file", "other" => "files"}}})
      subject = AvoLocaleShape.flatten({"avo" => {"file" => {"few" => {"one" => "pliki", "other" => "plików"}}}})

      # Malformed pluralization data: I18n resolves `avo.file` with a count and gets
      # a Hash back where a String belongs.
      expect(AvoLocaleShape.divergences(reference: reference, subject: subject)).to include(
        %(avo.file.few — added, and "few" is not a CLDR plural category)
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

    it "reports a key every translated locale carries as missing from the reference" do
      reference = AvoLocaleShape.flatten({"avo" => {"save" => "Save"}})
      subjects = [
        AvoLocaleShape.flatten({"avo" => {"save" => "Salvar", "close" => "Fechar"}}),
        AvoLocaleShape.flatten({"avo" => {"save" => "Enregistrer", "close" => "Fermer"}})
      ]

      orphans = AvoLocaleShape.orphaned_from_reference(reference: reference, subjects: subjects)

      expect(orphans).to eq(%w[avo.close])
      # And it drops out of the per-locale additions, so the same key is never
      # reported twice under two contradictory instructions.
      expect(AvoLocaleShape.divergences(reference: reference, subject: subjects.first, ignore: orphans)).to be_empty
    end

    it "leaves a key only some locales carry reported as an addition" do
      reference = AvoLocaleShape.flatten({"avo" => {"save" => "Save"}})
      subjects = [
        AvoLocaleShape.flatten({"avo" => {"save" => "Salvar", "close" => "Fechar"}}),
        AvoLocaleShape.flatten({"avo" => {"save" => "Enregistrer"}})
      ]

      expect(AvoLocaleShape.orphaned_from_reference(reference: reference, subjects: subjects)).to be_empty
      expect(AvoLocaleShape.divergences(reference: reference, subject: subjects.first)).to contain_exactly(
        %(avo.close — added, and "close" is not a CLDR plural category)
      )
    end
  end
end
