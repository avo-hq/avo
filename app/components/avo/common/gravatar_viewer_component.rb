# frozen_string_literal: true

class Avo::Common::GravatarViewerComponent < ViewComponent::Base
  def initialize(md5: nil, link: nil, default: nil, size: nil, rounded: false, link_to_resource: false, title: nil)
    @md5 = md5
    @link = link
    @default = default
    @size = size
    @rounded = rounded
    @link_to_resource = link_to_resource
    @title = title
  end
end
