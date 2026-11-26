module Avo
  module HarborTheme
    # The gem-shaped fixture, and the fixture for the default theme shape: a
    # dark look that owns every picker.
    class Theme < Avo::BaseTheme
      self.id = :harbor
      self.title = "Harbor"
      self.description = "Dummy-app gem theme fixture."
      self.scheme = :dark
    end
  end
end
