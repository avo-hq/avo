class ReleaseFish < Avo::BaseAction
  self.name = "Release fish"
  self.message = "Are you sure you want to release this fish?"

  def handle(**args)
    args[:models].each do |model|
      model.release
    end

    # @todo:
    succeed "((#{args[:models].count} fish released....))"
  end
end
