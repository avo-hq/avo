module Avo
  module HarborTheme
    class Theme < Avo::BaseTheme
      self.id = :harbor
      self.title = "Harbor"
      self.description = "Dummy-app gem theme fixture."
      self.lock = [:accent]
    end
  end
end
