# frozen_string_literal: true

class Avo::DeveloperWarningComponent < Avo::BaseComponent
  include Avo::ApplicationHelper

  prop :message, kind: :positional

  def render?
    Rails.env.development? || Rails.env.test?
  end

  def classes
    "w-full flex items-start gap-3 rounded-lg border border-orange-600/40 bg-orange-50 px-4 py-3 text-orange-950 dark:border-orange-500/30 dark:bg-orange-950/30 dark:text-orange-50"
  end

  def icon
    "tabler/filled/alert-triangle"
  end

  def sanitize_options
    {
      tags: %w[a code br],
      attributes: %w[href target rel class]
    }
  end
end
