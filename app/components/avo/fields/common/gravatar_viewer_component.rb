# frozen_string_literal: true

class Avo::Fields::Common::GravatarViewerComponent < Avo::BaseComponent
  prop :md5
  prop :link
  prop :default
  prop :size
  prop :rounded, default: false
  prop :link_to_record, default: false
  prop :title
end
