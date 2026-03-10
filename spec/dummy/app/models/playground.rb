class Playground < ApplicationRecord
  SELECT_OPTIONS = {
    "Draft" => "draft",
    "Review" => "review",
    "Published" => "published"
  }.freeze

  MULTI_SELECT_OPTIONS = {
    "Feature flags" => "feature_flags",
    "Insights" => "insights",
    "Automation" => "automation"
  }.freeze

  RADIO_OPTIONS = {
    "Low" => "low",
    "Medium" => "medium",
    "High" => "high"
  }.freeze

  BADGE_OPTIONS = {
    info: "draft",
    warning: "review",
    success: "published",
    danger: "archived"
  }.freeze

  STATUS_LOADING = %i[pending processing].freeze
  STATUS_FAILED = %i[failed errored].freeze
  STATUS_SUCCESS = %i[done shipped].freeze
  STATUS_NEUTRAL = %i[draft queued].freeze

  BOOLEAN_GROUP_OPTIONS = {
    "Email alerts" => :email_alerts,
    "SMS alerts" => :sms_alerts,
    "Weekly digest" => :weekly_digest
  }.freeze

  TAG_SUGGESTIONS = [
    "avo",
    "rails",
    "admin",
    "showcase"
  ].freeze

  has_one_attached :file_attachment
  has_many_attached :files_attachments
  has_rich_text :trix_content

  def avatar_url
    external_image_url.presence || "https://picsum.photos/80"
  end
end
