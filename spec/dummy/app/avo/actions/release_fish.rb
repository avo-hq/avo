class ReleaseFish < Avo::BaseAction
  self.name = "Release fish"

  def handle(**args)
    models, fields, current_user, resource = args.values_at(:models, :fields, :current_user, :resource)

    models.each do |model|
      model.release
    end
  end
end
