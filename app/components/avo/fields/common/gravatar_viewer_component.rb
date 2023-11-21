# frozen_string_literal: true

class Avo::Fields::Common::GravatarViewerComponent < ViewComponent::Base
  def initialize(md5: nil, link: nil, default: nil, size: nil, rounded: false, link_to_record: false, title: nil)
    @md5 = md5
    @link = link
    @default = default
    @size = size
    @rounded = rounded
    @link_to_record = link_to_record
    @title = title
  end
end
