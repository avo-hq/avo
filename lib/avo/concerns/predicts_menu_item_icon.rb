module Avo
  module Concerns
    module PredictsMenuItemIcon
      ICON_MAP = {
        user: "tabler/outline/users",
        customer: "tabler/outline/user",
        transaction: "tabler/outline/credit-card-pay",
        post: "tabler/outline/ballpen",
        comment: "tabler/outline/message",
        product: "tabler/outline/package",
        order: "tabler/outline/shopping-cart",
        category: "tabler/outline/folder",
        tag: "tabler/outline/tag",
        project: "tabler/outline/building-store",
        team: "tabler/outline/users-group",
        company: "tabler/outline/building",
        invoice: "tabler/outline/file-invoice",
        payment: "tabler/outline/cash",
        article: "tabler/outline/article",
        event: "tabler/outline/calendar-event",
        notification: "tabler/outline/bell",
        message: "tabler/outline/mail",
        setting: "tabler/outline/settings",
        report: "tabler/outline/chart-bar",
        task: "tabler/outline/checklist",
        review: "tabler/outline/star",
        photo: "tabler/outline/photo",
        image: "tabler/outline/photo",
        video: "tabler/outline/video",
        file: "tabler/outline/file",
        document: "tabler/outline/file-text",
        role: "tabler/outline/shield",
        permission: "tabler/outline/lock",
        subscription: "tabler/outline/credit-card",
        plan: "tabler/outline/list",
        address: "tabler/outline/map-pin",
        location: "tabler/outline/map-pin",
        country: "tabler/outline/globe",
        city: "tabler/outline/building-community",
        account: "tabler/outline/user-circle",
      }.freeze unless defined?(ICON_MAP)

      def icon_for_name(icon_name, predict: false)
        normalized_name = normalize_icon_name(icon_name)
        fallback_icon = ICON_MAP[normalized_name.to_sym]
        return fallback_icon unless predict

        predicted_icon = predict_tabler_icon_for(normalized_name)
        return "tabler/outline/#{predicted_icon}" if predicted_icon.present?

        fallback_icon
      end

      private

      def predict_tabler_icon_for(icon_name)
        return if icon_name.blank?

        tabler_icons = tabler_outline_icon_slugs
        return if tabler_icons.blank?

        return icon_name if tabler_icons.include?(icon_name)

        regex_candidate = best_regex_or_token_match(icon_name, tabler_icons)
        return regex_candidate if regex_candidate.present?

        best_fuzzy_match(icon_name, tabler_icons)
      end

      def best_regex_or_token_match(icon_name, tabler_icons)
        matching_icons = tabler_icons.filter_map do |tabler_icon|
          score = icon_similarity_score(icon_name, tabler_icon)
          [tabler_icon, score] if score >= 0.72
        end

        matching_icons.max_by { |(_, score)| score }&.first
      end

      def best_fuzzy_match(icon_name, tabler_icons)
        suggestions = DidYouMean::SpellChecker.new(dictionary: tabler_icons).correct(icon_name)
        suggestion = suggestions.first
        return if suggestion.blank?

        suggestion if icon_similarity_score(icon_name, suggestion) >= 0.6
      end

      def icon_similarity_score(icon_name, tabler_icon)
        source_tokens = icon_name.split("-")
        target_tokens = tabler_icon.split("-")

        overlap_score = (source_tokens & target_tokens).size.to_f / [source_tokens.size, target_tokens.size].max
        contains_bonus = (tabler_icon.include?(icon_name) || icon_name.include?(tabler_icon)) ? 0.2 : 0.0
        prefix_bonus = (tabler_icon.start_with?(icon_name) || icon_name.start_with?(tabler_icon)) ? 0.15 : 0.0

        [(0.65 * overlap_score) + (0.2 * bigram_jaccard(icon_name, tabler_icon)) + contains_bonus + prefix_bonus, 1.0].min
      end

      def bigram_jaccard(source, target)
        source_bigrams = bigrams_for(source)
        target_bigrams = bigrams_for(target)

        union = (source_bigrams | target_bigrams)
        return 0.0 if union.empty?

        (source_bigrams & target_bigrams).size.to_f / union.size
      end

      def bigrams_for(value)
        return [value] if value.length < 2

        value.chars.each_cons(2).map(&:join).uniq
      end

      def normalize_icon_name(icon_name)
        icon_name.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
      end

      def tabler_outline_icon_slugs
        @tabler_outline_icon_slugs ||= begin
          roots = [avo_icons_root, *avo_icons_roots_from_gem_paths].compact.map(&:to_s).uniq
          roots.flat_map do |root|
            tabler_outline_path = File.join(root, "lib", "assets", "svgs", "tabler", "outline", "*.svg")
            Dir.glob(tabler_outline_path).map { |path| File.basename(path, ".svg") }
          end.uniq
        end
      end

      def avo_icons_root
        return ::Avo::Icons.root if defined?(::Avo::Icons) && ::Avo::Icons.respond_to?(:root)

        gem_spec = Gem.loaded_specs["avo-icons"] || Gem::Specification.find_all_by_name("avo-icons").first
        Pathname.new(gem_spec.full_gem_path) if gem_spec.present?
      end

      def avo_icons_roots_from_gem_paths
        Gem.path.flat_map do |gem_path|
          Dir.glob(File.join(gem_path, "gems", "avo-icons-*")).map { |path| Pathname.new(path) }
        end
      end
    end
  end
end
