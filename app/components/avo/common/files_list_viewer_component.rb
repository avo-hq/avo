# frozen_string_literal: true

class Avo::Common::FilesListViewerComponent < ViewComponent::Base
  def initialize(field:, resource:)
    @field = field
    @resource = resource
  end
end
